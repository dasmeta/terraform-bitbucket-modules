# terraform-bitbucket-modules
Terraform modules for Bitbucket
<!-- BEGINNING OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 1.3.0 |

## Providers

No providers.

## Modules

| Name | Source | Version |
|------|--------|---------|
| <a name="module_runner"></a> [runner](#module\_runner) | ./modules/runner/ | n/a |

## Resources

No resources.

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_accountUuid"></a> [accountUuid](#input\_accountUuid) | Account Uuid | `string` | n/a | yes |
| <a name="input_create_namespace"></a> [create\_namespace](#input\_create\_namespace) | Create namespace or use existing one | `bool` | `true` | no |
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
