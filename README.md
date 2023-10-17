# terraform-bitbucket-modules
Terraform modules for Bitbucket
<!-- BEGINNING OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
## Requirements

No requirements.

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
| <a name="input_namespace"></a> [namespace](#input\_namespace) | Namespace name | `string` | `"runner"` | no |
| <a name="input_oauthClientId"></a> [oauthClientId](#input\_oauthClientId) | Oauth Client | `string` | n/a | yes |
| <a name="input_oauthClientSecret"></a> [oauthClientSecret](#input\_oauthClientSecret) | Oauth Client Secret | `string` | n/a | yes |
| <a name="input_runnerUuid"></a> [runnerUuid](#input\_runnerUuid) | Runner Uuid | `string` | n/a | yes |

## Outputs

No outputs.
<!-- END OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
