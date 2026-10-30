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

variable "runner_image" {
  type        = string
  description = "Bitbucket runner container image reference (tag, digest, or private mirror)"
  default     = "docker-public.packages.atlassian.com/sox/atlassian/bitbucket-pipelines-runner:6.1.3"
  nullable    = false
}

variable "dind_image" {
  type        = string
  description = "Docker-in-Docker container image reference (tag, digest, or private mirror)"
  default     = "docker:29.9.2-dind"
  nullable    = false
}

variable "runner_image_pull_policy" {
  type        = string
  description = "Image pull policy for the Bitbucket runner container; null uses the provider default"
  default     = null
  nullable    = true
}

variable "dind_image_pull_policy" {
  type        = string
  description = "Image pull policy for the Docker-in-Docker container; null uses the provider default"
  default     = null
  nullable    = true
}

variable "runner_resources" {
  type = object({
    requests = optional(map(string), {})
    limits   = optional(map(string), {})
  })
  description = "Resource requests and limits for the Bitbucket runner container"
  default     = {}
  nullable    = false
}

variable "dind_resources" {
  type = object({
    requests = optional(map(string), {})
    limits   = optional(map(string), {})
  })
  description = "Resource requests and limits for the Docker-in-Docker container"
  default     = {}
  nullable    = false
}

variable "runner_security_context" {
  type = object({
    privileged                 = optional(bool)
    allow_privilege_escalation = optional(bool)
    read_only_root_filesystem  = optional(bool)
    run_as_non_root            = optional(bool)
    seccomp_profile = optional(object({
      type              = string
      localhost_profile = optional(string)
    }))
  })
  description = "Security context settings for the Bitbucket runner container"
  default     = {}
  nullable    = false
}

variable "dind_security_context" {
  type = object({
    privileged                 = optional(bool, true)
    allow_privilege_escalation = optional(bool)
    read_only_root_filesystem  = optional(bool)
    run_as_non_root            = optional(bool)
    seccomp_profile = optional(object({
      type              = string
      localhost_profile = optional(string)
    }))
  })
  description = "Security context settings for the Docker-in-Docker container; privileged defaults to true"
  default     = {}
  nullable    = false
}

variable "pod_security_context" {
  type = object({
    seccomp_profile = optional(object({
      type              = string
      localhost_profile = optional(string)
    }))
  })
  description = "Pod-level seccomp profile for the runner Pod template"
  default     = {}
  nullable    = false
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

variable "pod_annotations" {
  type        = map(string)
  description = "Annotations to apply to the runner Pod template"
  default     = {}
  nullable    = false
}

variable "node_selector" {
  type        = map(string)
  description = "Node labels required for scheduling the runner Pod"
  default     = {}
  nullable    = false
}

variable "tolerations" {
  type = list(object({
    key                = optional(string, "")
    operator           = optional(string, "Equal")
    value              = optional(string, "")
    effect             = optional(string, "")
    toleration_seconds = optional(number)
  }))
  description = "Node taint tolerations for the runner Pod"
  default     = []
  nullable    = false
}

variable "image_pull_secrets" {
  type = list(object({
    name = string
  }))
  description = "List of image pull secret names for the runner cronjob pod"
  default     = []
}
