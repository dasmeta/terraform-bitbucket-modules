resource "bitbucket_deployment_variable" "depl-vars" {

  for_each = { for item in local.variables_flat : "${item.deploy}-${item.variable.key}" => item }

  deployment = bitbucket_deployment.depl[each.value.deploy].id
  key        = each.value.variable.key
  value      = each.value.variable.value
  secured    = each.value.variable.secured
}
