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

variable "cron_schedule" {
  type        = string
  description = "Cronjob schedule"
  default     = "* * * * *"
