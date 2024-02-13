# Terraform module to manage repository `Deployments`

## About

---
Deployment is environment which has its own variables to use in pipelines

## Provider configuration

---
```hcl
terraform {
  required_providers {
    bitbucket = {
      source  = "DrFaust92/bitbucket"
      version = "2.30.2"
    }
  }
}
```
## Usage

---
```hcl
module "deployments" {

  source = "./deployments"
  deployments = local.deployments
  repository_id = "my-repository-xxxx-id"

}

locals {
  deployments = [
    {
     name = "development1"
     stage = "Test"
     variables = {
       "key1" = ["value1", "secured"]
       "key2" = ["value2", "secured"]
     }
    },

    {
     name = "development1"
     stage = "Test"
     variables = {
       "key1" = ["value1", "secured"]
       "key2" = ["value2"]
     }
    }

  ]
}
```
<!-- BEGINNING OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_bitbucket"></a> [bitbucket](#requirement\_bitbucket) | 2.31.0 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_bitbucket"></a> [bitbucket](#provider\_bitbucket) | 2.31.0 |

## Modules

No modules.

## Resources

| Name | Type |
|------|------|
| [bitbucket_deployment.depl](https://registry.terraform.io/providers/DrFaust92/bitbucket/2.31.0/docs/resources/deployment) | resource |
| [bitbucket_deployment_variable.depl-vars](https://registry.terraform.io/providers/DrFaust92/bitbucket/2.31.0/docs/resources/deployment_variable) | resource |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_deployments"></a> [deployments](#input\_deployments) | n/a | <pre>list(object({<br>    name  = string<br>    stage = string<br>    variables = list(object({<br>      name    = string<br>      value   = string<br>      secured = bool<br>    }))<br>  }))</pre> | n/a | yes |
| <a name="input_repository_id"></a> [repository\_id](#input\_repository\_id) | n/a | `string` | n/a | yes |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_variables"></a> [variables](#output\_variables) | n/a |
<!-- END OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
