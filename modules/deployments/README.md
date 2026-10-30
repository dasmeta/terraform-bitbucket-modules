# Terraform module to manage repository deployments

Manage deployment environments and their pipeline variables for an existing
Bitbucket repository. This module does not create the repository or project.

## Usage

```hcl
terraform {
  required_providers {
    bitbucket = {
      source  = "DrFaust92/bitbucket"
      version = "2.53.0"
    }
  }
}

module "deployments" {
  source = "./terraform-bitbucket-modules/modules/deployments"

  repository_id = "example-workspace/example-repository"
  deployments = [
    {
      name  = "development"
      stage = "Test"
      variables = [
        { name = "API_URL", value = "https://development.example.com", secured = false },
        { name = "DEPLOY_TOKEN", value = var.development_token, secured = true }
      ]
    },
    {
      name      = "production"
      stage     = "Production"
      variables = []
    }
  ]
}
```

Use a unique deployment name for each environment. `variables` is a list of
objects with `name`, `value`, and Boolean `secured` fields; use `[]` when an
environment needs no variables. Configure authentication using the
[Bitbucket provider documentation](https://registry.terraform.io/providers/DrFaust92/bitbucket/2.53.0/docs).

The provider is pinned to 2.53.0. When upgrading an existing installation, run
`terraform init -upgrade` and review the lockfile and the plan against the actual
state before applying. The resource addresses and input shape remain unchanged.
Restore the prior provider configuration and lockfile to roll back, and review
state compatibility before applying with an older provider.

The [minimal example](tests/minimal-example) creates one environment; the
[full example](tests/full-example) shows variables across two environments.
From the repository root, Terraform >= 1.7 can run credential-free mocked plans:

```sh
terraform -chdir=modules/deployments init -backend=false
terraform -chdir=modules/deployments test
```

<!-- BEGINNING OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_bitbucket"></a> [bitbucket](#requirement\_bitbucket) | 2.53.0 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_bitbucket"></a> [bitbucket](#provider\_bitbucket) | 2.53.0 |

## Modules

No modules.

## Resources

| Name | Type |
|------|------|
| [bitbucket_deployment.depl](https://registry.terraform.io/providers/DrFaust92/bitbucket/2.53.0/docs/resources/deployment) | resource |
| [bitbucket_deployment_variable.depl-vars](https://registry.terraform.io/providers/DrFaust92/bitbucket/2.53.0/docs/resources/deployment_variable) | resource |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_deployments"></a> [deployments](#input\_deployments) | n/a | <pre>list(object({<br/>    name  = string<br/>    stage = string<br/>    variables = list(object({<br/>      name    = string<br/>      value   = string<br/>      secured = bool<br/>    }))<br/>  }))</pre> | n/a | yes |
| <a name="input_repository_id"></a> [repository\_id](#input\_repository\_id) | n/a | `string` | n/a | yes |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_variables"></a> [variables](#output\_variables) | n/a |
<!-- END OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
