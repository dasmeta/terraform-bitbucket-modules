# runner

<!-- BEGINNING OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_kubernetes"></a> [kubernetes](#requirement\_kubernetes) | 2.23.0 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_kubernetes"></a> [kubernetes](#provider\_kubernetes) | 2.23.0 |

## Modules

No modules.

## Resources

| Name | Type |
|------|------|
| [kubernetes_cron_job_v.runner_cronjob](https://registry.terraform.io/providers/hashicorp/kubernetes/2.23.0/docs/resources/cron_job_v) | resource |
| [kubernetes_namespace_v1.runner](https://registry.terraform.io/providers/hashicorp/kubernetes/2.23.0/docs/resources/namespace_v1) | resource |
| [kubernetes_secret.runner](https://registry.terraform.io/providers/hashicorp/kubernetes/2.23.0/docs/resources/secret) | resource |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_accountUuid"></a> [accountUuid](#input\_accountUuid) | Account Uuid | `string` | n/a | yes |
| <a name="input_create_namespace"></a> [create\_namespace](#input\_create\_namespace) | Create namespace or use existing one | `bool` | `true` | no |
| <a name="input_cron_schedule"></a> [cron\_schedule](#input\_cron\_schedule) | Cronjob schedule | `string` | `"*/5 * * * *"` | no |
| <a name="input_namespace"></a> [namespace](#input\_namespace) | Namespace name | `string` | `"runner"` | no |
| <a name="input_oauthClientId"></a> [oauthClientId](#input\_oauthClientId) | Oauth Client | `string` | n/a | yes |
| <a name="input_oauthClientSecret"></a> [oauthClientSecret](#input\_oauthClientSecret) | Oauth Client Secret | `string` | n/a | yes |
| <a name="input_runnerUuid"></a> [runnerUuid](#input\_runnerUuid) | Runner Uuid | `string` | n/a | yes |

## Outputs

No outputs.
<!-- END OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
