# basic

Configuration example for the runner submodule with Kubernetes provider 3.4.0,
runner 6.1.3, and Docker-in-Docker 29.9.2. The example uses `~/.kube/config`;
adapt the provider configuration and replace OAuth/UUID placeholders for the
intended cluster. The referenced image pull secret must exist in the runner
namespace when using a private registry.

Run `terraform init -backend=false` and `terraform validate` here to check the
configuration. This directory contains an example rather than assertions.
Credential-free native mock tests live at the repository root and require
Terraform >= 1.7 only to run the test suite:

```sh
terraform init -backend=false
terraform test -filter=tests/runner_images.tftest.hcl
```

Before production, inspect the real plan and run a staging pipeline covering
checkout, Docker build/run/push, cache and artifact handling. See the
[runner module guidance](../../README.md) for provider upgrade and image rollout
considerations.

<!-- BEGINNING OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 1.3.0 |
| <a name="requirement_kubernetes"></a> [kubernetes](#requirement\_kubernetes) | 3.4.0 |

## Providers

No providers.

## Modules

| Name | Source | Version |
|------|--------|---------|
| <a name="module_test"></a> [test](#module\_test) | ../.. | n/a |

## Resources

No resources.

## Inputs

No inputs.

## Outputs

No outputs.
<!-- END OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
