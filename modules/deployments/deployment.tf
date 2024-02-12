resource "bitbucket_deployment" "depl" {
  for_each = { for deployment in var.deployments : deployment.name => deployment }

  repository = var.repository_id
  name       = each.value.name
  stage      = each.value.stage
}
