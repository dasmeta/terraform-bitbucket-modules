variable "deployments" {
  type = list(object({
    name  = string
    stage = string
    variables = list(object({
      name    = string
      value   = string
      secured = bool
    }))
  }))
}

variable "repository_id" {
  type = string
}
