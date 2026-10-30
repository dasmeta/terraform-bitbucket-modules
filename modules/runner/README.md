# runner

This provider and default-image upgrade requires a **major release**. Existing
consumers must follow the [migration notes](../../docs/migrations/runner-provider-v3.md).

## Runner images

The default runner image is
`docker-public.packages.atlassian.com/sox/atlassian/bitbucket-pipelines-runner:6.1.3`;
the default Docker-in-Docker image is `docker:29.9.2-dind`. Omit either optional
input or set it to `null` to use its default. Empty or whitespace-only image
references are rejected.

Override either image independently with a full tag, digest, or private mirror:

```hcl
module "runner" {
  source = "./terraform-bitbucket-modules/modules/runner"

  oauthClientId     = var.oauthClientId
  oauthClientSecret = var.oauthClientSecret
  accountUuid       = var.accountUuid
  runnerUuid        = var.runnerUuid

  runner_image = "docker-public.packages.atlassian.com/sox/atlassian/bitbucket-pipelines-runner:6.1.3"
  dind_image   = "docker:29.9.2-dind"

  # Digest alternative: replace <verified-digest> with the actual SHA-256 digest.
  # runner_image = "docker-public.packages.atlassian.com/sox/atlassian/bitbucket-pipelines-runner@sha256:<verified-digest>"
  # Private mirror alternative; configure image_pull_secrets when required.
  # dind_image = "registry.example.com/ci/docker:29.9.2-dind"
}
```

Validate checkout, Docker build/run/push, caches, and artifacts in a staging
pipeline before production; image availability and API overlap do not prove
runtime compatibility. See the [migration notes](../../docs/migrations/runner-provider-v3.md).

The CronJob update affects future Jobs. Existing Jobs retain their old images,
and `Forbid` prevents the next scheduled Job while one remains active. Manually
created Jobs are outside that protection. Drain active pipeline work and stop the
old Job before starting a replacement to avoid overlap. Capture the prior runner and DinD
references and resolved digests first, particularly the previously floating runner
image. Roll back by setting the two inputs to those known prior references or
digests, applying the configuration, and draining and stopping the current Job to
allow a replacement with the rollback images.

## Resource requests and limits

Configure `runner_resources` and `dind_resources` independently. Each accepts
optional `requests` and `limits` maps containing Kubernetes quantity strings.
For example, inside the module call:

```hcl
runner_resources = {
  requests = { cpu = "250m", memory = "512Mi" }
  limits   = { memory = "1Gi" }
}
dind_resources = {
  requests = { cpu = "500m", memory = "1Gi" }
  limits   = { cpu = "2", memory = "4Gi" }
}
```

These values illustrate syntax; select sizing for your workload. Either map may
be omitted. Omitted inputs, `{}`, and `null` leave resources unset; requests-only
or limits-only settings are supported. Blank/null quantity entries are rejected.
Other Kubernetes resource names such as `ephemeral-storage` pass through unchanged.
Full quantity syntax and request/limit consistency are checked by the provider
and Kubernetes. Cluster admission defaults may still supply requests or limits.

The grouped inputs require Terraform >= 1.3. Changes affect future Jobs; existing
running Jobs keep their original resource settings.

## Container security context

Set `runner_security_context` and `dind_security_context` independently using
optional boolean fields: `privileged`, `allow_privilege_escalation`,
`read_only_root_filesystem`, and `run_as_non_root`. For example, the DinD settings
shown in a Kubernetes manifest map to:

```hcl
dind_security_context = {
  privileged                 = true
  allow_privilege_escalation  = true
  read_only_root_filesystem  = false
  run_as_non_root             = false
}
```

The same fields are available in `runner_security_context`. Explicit `false`
values are preserved. Omitting the runner input, setting it to `{}`/`null`, or
leaving all fields null emits no runner security-context block. DinD keeps
`privileged = true` by default, including for `{}`/`null`; explicitly set
`privileged = false` to override it. Other fields are omitted when unset/null.

These four flags are container settings. Optional seccomp profiles at container
and Pod levels are described below; UID/GID and capabilities are not exposed. Restrictive combinations must match the chosen image and
runtime: the default rootful DinD normally needs privileged/root/writable behavior.
Kubernetes treats privilege escalation as allowed for privileged containers,
even if `allow_privilege_escalation = false`. See the
[Kubernetes security-context reference](https://kubernetes.io/docs/tasks/configure-pod-container/security-context/).
Changes affect future Jobs only.

## Pod annotations and disruption protection

Use `pod_annotations` to add annotations to runner Pod-template metadata:

```hcl
pod_annotations = {
  "karpenter.sh/do-not-disrupt" = "true"
}
```

This is Karpenter's disruption-protection annotation, not a node taint or Pod
toleration. It takes effect only with a controller that recognizes it. Karpenter
blocks voluntary disruption with documented exceptions; it does not guarantee
protection from expiration, repair or forceful termination. See
[Karpenter annotations](https://karpenter.sh/docs/reference/annotations/) and
[disruption behavior](https://karpenter.sh/docs/concepts/disruption/).

The input accepts other annotation keys too. Omission, `{}`, or `null` adds no
custom annotations. Values are strings; empty strings are valid, null entries
are rejected. Existing `accountUuid`/`runnerUuid` Pod labels remain unchanged.
This module input affects future Pods; existing Pods retain their annotations.

## Seccomp profiles and image pull policy

Container security-context inputs also accept an optional `seccomp_profile`.
`pod_security_context` provides the Pod-level profile, independently of the
container settings. For example, to preserve explicit settings from a CronJob:

```hcl
runner_image_pull_policy = "Always"
dind_image_pull_policy   = "IfNotPresent"
runner_security_context = {
  seccomp_profile = { type = "Unconfined" }
}
pod_security_context = {
  seccomp_profile = { type = "Unconfined" }
}
```

A container profile overrides the Pod profile. Supported types are
`Unconfined`, `RuntimeDefault`, and `Localhost`. `Localhost` additionally requires
`localhost_profile`, for example `profiles/runner.json`, preconfigured on the
node; other types omit that field. `Unconfined` disables seccomp filtering and
is shown for live-configuration parity, not enabled by default. See the
[Kubernetes seccomp documentation](https://kubernetes.io/docs/tutorials/security/seccomp/).

Omitted/null profiles emit no seccomp blocks. A supplied profile requires `type`. Pull-policy inputs default to `null`
(provider/Kubernetes defaulting); explicit values are `Always`, `IfNotPresent`
or `Never`. Existing four boolean security flags and DinD privileged default
remain available. Updates affect future Jobs/Pods only.

## Node selection and tolerations

`node_selector` and `tolerations` are optional Pod-level inputs. Defaults are
`{}` and `[]`, so the module adds no placement constraints or tolerations unless
configured. Explicit `null` uses the same empty defaults. Both containers share
the Pod's scheduling settings.

To select nodes labelled `nodetype=regular`:

```hcl
node_selector = { nodetype = "regular" }
tolerations   = []
```

A toleration permits a matching taint; it does not select the nodepool. If the
selected nodes actually have a taint such as `dedicated=runner:NoSchedule`, add:

```hcl
tolerations = [{
  key      = "dedicated"
  operator = "Equal"
  value    = "runner"
  effect   = "NoSchedule"
}]
```

Only add tolerations matching your real node taints. `operator` defaults to
`Equal` and also supports `Exists`; `Exists` requires an empty value, and an
empty key requires `Exists`. Effect may be omitted or set to `NoSchedule`,
`PreferNoSchedule`, or `NoExecute`. For `NoExecute`, optional
`toleration_seconds` accepts a nonnegative integer. The module does not create
nodepools or add node taints. Actual labels, capacity and other scheduling rules
still determine whether a new Pod can run. Existing running Jobs are unchanged.

## Provider upgrade

Kubernetes provider is pinned to 3.4.0. Run `terraform init -upgrade` in the
consuming configuration and review its plan before applying. Namespace label and
annotation entries must contain non-null strings with this provider version.
The existing `kubernetes_secret.runner` address is retained to preserve deployed
Secrets: 3.4.0 still supports this deprecated type and does not support an
automatic cross-type state move to `kubernetes_secret_v1`. A future type migration
needs a separate state-aware procedure; do not simply rename the resource.

<!-- BEGINNING OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 1.3.0 |
| <a name="requirement_kubernetes"></a> [kubernetes](#requirement\_kubernetes) | 3.4.0 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_kubernetes"></a> [kubernetes](#provider\_kubernetes) | 3.4.0 |

## Modules

No modules.

## Resources

| Name | Type |
|------|------|
| [kubernetes_cron_job_v1.runner_cronjob](https://registry.terraform.io/providers/hashicorp/kubernetes/3.4.0/docs/resources/cron_job_v1) | resource |
| [kubernetes_namespace_v1.runner](https://registry.terraform.io/providers/hashicorp/kubernetes/3.4.0/docs/resources/namespace_v1) | resource |
| [kubernetes_secret.runner](https://registry.terraform.io/providers/hashicorp/kubernetes/3.4.0/docs/resources/secret) | resource |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_accountUuid"></a> [accountUuid](#input\_accountUuid) | Account Uuid | `string` | n/a | yes |
| <a name="input_create_namespace"></a> [create\_namespace](#input\_create\_namespace) | Create namespace or use existing one | `bool` | `true` | no |
| <a name="input_cron_schedule"></a> [cron\_schedule](#input\_cron\_schedule) | Cronjob schedule | `string` | `"* * * * *"` | no |
| <a name="input_dind_image"></a> [dind\_image](#input\_dind\_image) | Docker-in-Docker container image reference (tag, digest, or private mirror) | `string` | `"docker:29.9.2-dind"` | no |
| <a name="input_dind_image_pull_policy"></a> [dind\_image\_pull\_policy](#input\_dind\_image\_pull\_policy) | Image pull policy for the Docker-in-Docker container; null uses the provider default | `string` | `null` | no |
| <a name="input_dind_resources"></a> [dind\_resources](#input\_dind\_resources) | Resource requests and limits for the Docker-in-Docker container | <pre>object({<br/>    requests = optional(map(string), {})<br/>    limits   = optional(map(string), {})<br/>  })</pre> | `{}` | no |
| <a name="input_dind_security_context"></a> [dind\_security\_context](#input\_dind\_security\_context) | Security context settings for the Docker-in-Docker container; privileged defaults to true | <pre>object({<br/>    privileged                 = optional(bool, true)<br/>    allow_privilege_escalation = optional(bool)<br/>    read_only_root_filesystem  = optional(bool)<br/>    run_as_non_root            = optional(bool)<br/>    seccomp_profile = optional(object({<br/>      type              = string<br/>      localhost_profile = optional(string)<br/>    }))<br/>  })</pre> | `{}` | no |
| <a name="input_image_pull_secrets"></a> [image\_pull\_secrets](#input\_image\_pull\_secrets) | List of image pull secret names for the runner cronjob pod | <pre>list(object({<br/>    name = string<br/>  }))</pre> | `[]` | no |
| <a name="input_namespace"></a> [namespace](#input\_namespace) | Namespace name | `string` | `"runner"` | no |
| <a name="input_namespace_labels"></a> [namespace\_labels](#input\_namespace\_labels) | Labels to apply to the runner namespace when it is created | `map(string)` | `{}` | no |
| <a name="input_node_selector"></a> [node\_selector](#input\_node\_selector) | Node labels required for scheduling the runner Pod | `map(string)` | `{}` | no |
| <a name="input_oauthClientId"></a> [oauthClientId](#input\_oauthClientId) | Oauth Client | `string` | n/a | yes |
| <a name="input_oauthClientSecret"></a> [oauthClientSecret](#input\_oauthClientSecret) | Oauth Client Secret | `string` | n/a | yes |
| <a name="input_pod_annotations"></a> [pod\_annotations](#input\_pod\_annotations) | Annotations to apply to the runner Pod template | `map(string)` | `{}` | no |
| <a name="input_pod_security_context"></a> [pod\_security\_context](#input\_pod\_security\_context) | Pod-level seccomp profile for the runner Pod template | <pre>object({<br/>    seccomp_profile = optional(object({<br/>      type              = string<br/>      localhost_profile = optional(string)<br/>    }))<br/>  })</pre> | `{}` | no |
| <a name="input_runnerUuid"></a> [runnerUuid](#input\_runnerUuid) | Runner Uuid | `string` | n/a | yes |
| <a name="input_runner_image"></a> [runner\_image](#input\_runner\_image) | Bitbucket runner container image reference (tag, digest, or private mirror) | `string` | `"docker-public.packages.atlassian.com/sox/atlassian/bitbucket-pipelines-runner:6.1.3"` | no |
| <a name="input_runner_image_pull_policy"></a> [runner\_image\_pull\_policy](#input\_runner\_image\_pull\_policy) | Image pull policy for the Bitbucket runner container; null uses the provider default | `string` | `null` | no |
| <a name="input_runner_resources"></a> [runner\_resources](#input\_runner\_resources) | Resource requests and limits for the Bitbucket runner container | <pre>object({<br/>    requests = optional(map(string), {})<br/>    limits   = optional(map(string), {})<br/>  })</pre> | `{}` | no |
| <a name="input_runner_security_context"></a> [runner\_security\_context](#input\_runner\_security\_context) | Security context settings for the Bitbucket runner container | <pre>object({<br/>    privileged                 = optional(bool)<br/>    allow_privilege_escalation = optional(bool)<br/>    read_only_root_filesystem  = optional(bool)<br/>    run_as_non_root            = optional(bool)<br/>    seccomp_profile = optional(object({<br/>      type              = string<br/>      localhost_profile = optional(string)<br/>    }))<br/>  })</pre> | `{}` | no |
| <a name="input_tolerations"></a> [tolerations](#input\_tolerations) | Node taint tolerations for the runner Pod | <pre>list(object({<br/>    key                = optional(string, "")<br/>    operator           = optional(string, "Equal")<br/>    value              = optional(string, "")<br/>    effect             = optional(string, "")<br/>    toleration_seconds = optional(number)<br/>  }))</pre> | `[]` | no |

## Outputs

No outputs.
<!-- END OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
