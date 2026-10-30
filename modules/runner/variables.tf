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

  validation {
    condition     = length(trimspace(var.runner_image)) > 0
    error_message = "runner_image must be a nonblank container image reference."
  }
}

variable "dind_image" {
  type        = string
  description = "Docker-in-Docker container image reference (tag, digest, or private mirror)"
  default     = "docker:29.9.2-dind"
  nullable    = false

  validation {
    condition     = length(trimspace(var.dind_image)) > 0
    error_message = "dind_image must be a nonblank container image reference."
  }
}

variable "runner_image_pull_policy" {
  type        = string
  description = "Image pull policy for the Bitbucket runner container; null uses the provider default"
  default     = null
  nullable    = true

  validation {
    condition     = var.runner_image_pull_policy == null ? true : contains(["Always", "Never", "IfNotPresent"], var.runner_image_pull_policy)
    error_message = "runner_image_pull_policy must be null, Always, Never, or IfNotPresent."
  }
}

variable "dind_image_pull_policy" {
  type        = string
  description = "Image pull policy for the Docker-in-Docker container; null uses the provider default"
  default     = null
  nullable    = true

  validation {
    condition     = var.dind_image_pull_policy == null ? true : contains(["Always", "Never", "IfNotPresent"], var.dind_image_pull_policy)
    error_message = "dind_image_pull_policy must be null, Always, Never, or IfNotPresent."
  }
}

variable "runner_resources" {
  type = object({
    requests = optional(map(string), {})
    limits   = optional(map(string), {})
  })
  description = "Resource requests and limits for the Bitbucket runner container"
  default     = {}
  nullable    = false

  validation {
    condition = alltrue([
      for value in concat(values(var.runner_resources.requests), values(var.runner_resources.limits)) :
      value == null ? false : length(trimspace(value)) > 0
    ])
    error_message = "runner_resources requests and limits must contain non-null, nonblank resource quantities."
  }
}

variable "dind_resources" {
  type = object({
    requests = optional(map(string), {})
    limits   = optional(map(string), {})
  })
  description = "Resource requests and limits for the Docker-in-Docker container"
  default     = {}
  nullable    = false

  validation {
    condition = alltrue([
      for value in concat(values(var.dind_resources.requests), values(var.dind_resources.limits)) :
      value == null ? false : length(trimspace(value)) > 0
    ])
    error_message = "dind_resources requests and limits must contain non-null, nonblank resource quantities."
  }
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

  validation {
    condition = var.runner_security_context.seccomp_profile == null ? true : try(
      contains(["Localhost", "RuntimeDefault", "Unconfined"], var.runner_security_context.seccomp_profile.type) &&
      (var.runner_security_context.seccomp_profile.type == "Localhost" ?
        length(trimspace(var.runner_security_context.seccomp_profile.localhost_profile)) > 0 :
      var.runner_security_context.seccomp_profile.localhost_profile == null),
      false
    )
    error_message = "runner_security_context seccomp type must be Localhost, RuntimeDefault, or Unconfined; only Localhost requires a nonblank localhost_profile."
  }
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

  validation {
    condition = var.dind_security_context.seccomp_profile == null ? true : try(
      contains(["Localhost", "RuntimeDefault", "Unconfined"], var.dind_security_context.seccomp_profile.type) &&
      (var.dind_security_context.seccomp_profile.type == "Localhost" ?
        length(trimspace(var.dind_security_context.seccomp_profile.localhost_profile)) > 0 :
      var.dind_security_context.seccomp_profile.localhost_profile == null),
      false
    )
    error_message = "dind_security_context seccomp type must be Localhost, RuntimeDefault, or Unconfined; only Localhost requires a nonblank localhost_profile."
  }
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

  validation {
    condition = var.pod_security_context.seccomp_profile == null ? true : try(
      contains(["Localhost", "RuntimeDefault", "Unconfined"], var.pod_security_context.seccomp_profile.type) &&
      (var.pod_security_context.seccomp_profile.type == "Localhost" ?
        length(trimspace(var.pod_security_context.seccomp_profile.localhost_profile)) > 0 :
      var.pod_security_context.seccomp_profile.localhost_profile == null),
      false
    )
    error_message = "pod_security_context seccomp type must be Localhost, RuntimeDefault, or Unconfined; only Localhost requires a nonblank localhost_profile."
  }
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

variable "pod_annotations" {
  type        = map(string)
  description = "Annotations to apply to the runner Pod template"
  default     = {}
  nullable    = false

  validation {
    condition     = alltrue([for value in values(var.pod_annotations) : value != null])
    error_message = "pod_annotations values must be non-null strings."
  }
}

variable "node_selector" {
  type        = map(string)
  description = "Node labels required for scheduling the runner Pod"
  default     = {}
  nullable    = false

  validation {
    condition     = alltrue([for key, value in var.node_selector : length(trimspace(key)) > 0 && value != null])
    error_message = "node_selector must contain nonblank label keys and non-null label values."
  }
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

  validation {
    condition = alltrue([
      for toleration in var.tolerations : toleration == null ? false : (
        contains(["Equal", "Exists"], toleration.operator) &&
        contains(["", "NoSchedule", "PreferNoSchedule", "NoExecute"], toleration.effect) &&
        (toleration.key != "" || toleration.operator == "Exists") &&
        (toleration.operator != "Exists" || toleration.value == "")
      )
    ])
    error_message = "tolerations entries must be non-null, use operator Equal or Exists and a supported effect; an empty key requires Exists, and Exists requires an empty value."
  }

  validation {
    condition = alltrue([
      for toleration in var.tolerations : toleration == null ? true : (
        toleration.toleration_seconds == null ? true : (
          toleration.effect == "NoExecute" &&
          toleration.toleration_seconds >= 0 &&
          floor(toleration.toleration_seconds) == toleration.toleration_seconds
        )
      )
    ])
    error_message = "toleration_seconds must be omitted or a nonnegative integer with effect NoExecute."
  }
}

variable "image_pull_secrets" {
  type = list(object({
    name = string
  }))
  description = "List of image pull secret names for the runner cronjob pod"
  default     = []
}
