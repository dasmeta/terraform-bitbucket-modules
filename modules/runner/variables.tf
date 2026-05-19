variable "oauthClientId" {
  type        = string
  description = "Oauth Client"
}

variable "oauthClientSecret" {
  type        = string
  description = "Oauth Client Secret"
}

variable "accountUuid" {
  type        = string
  description = "Account Uuid"
}

variable "runnerUuid" {
  type        = string
  description = "Runner Uuid"
}

variable "namespace" {
  type        = string
  description = "Namespace name"
  default     = "runner"
}

variable "create_namespace" {
  type        = bool
  description = "Create namespace or use existing one"
  default     = true
}

variable "namespace_labels" {
  type        = map(string)
  description = "Labels to apply to the runner namespace when it is created"
  default     = {}
}

variable "cron_schedule" {
  type        = string
  description = "Cronjob schedule"
  default     = "* * * * *" # Run every minute
}

variable "image_pull_secrets" {
  type = list(object({
    name = string
  }))
  description = "List of image pull secret names for the runner cronjob pod"
  default     = []
}
