# minimal-example

Configures one deployment environment for an existing repository, without
variables. Replace the example repository identifier and configure Bitbucket
provider authentication before planning against a real account. `terraform init
-backend=false` and `terraform validate` check the example without applying it.

Credential-free rendering checks run from the repository root with Terraform >= 1.7:
`terraform -chdir=modules/deployments test`.

<!-- BEGINNING OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
## Requirements

No requirements.

## Providers

No providers.

## Modules

| Name | Source | Version |
|------|--------|---------|
| <a name="module_deployments"></a> [deployments](#module\_deployments) | ../.. | n/a |

## Resources

No resources.

## Inputs

No inputs.

## Outputs

No outputs.
<!-- END OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
