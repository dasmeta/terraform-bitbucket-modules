locals {
  variables_flat = flatten([for depl in var.deployments : [
    for variable in depl.variables : {
      deploy : depl.name
      variable : {
        key : variable.name,
        value : variable.value,
        secured : variable.secured
      }
    }
  ]])
}
