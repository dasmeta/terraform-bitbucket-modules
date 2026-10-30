resource "kubernetes_cron_job_v1" "runner_cronjob" {
  metadata {
    name      = "runner-cronjob"
    namespace = var.namespace
  }

  spec {
    schedule                      = var.cron_schedule # This schedule runs the job every hour
    concurrency_policy            = "Forbid"
    successful_jobs_history_limit = 3
    failed_jobs_history_limit     = 1

    job_template {
      metadata {
        name = "runner-cronjob"
      }
      spec {
        template {
          metadata {
            annotations = var.pod_annotations
            labels = {
              accountUuid = var.accountUuid
              runnerUuid  = var.runnerUuid
            }
          }

          spec {
            node_selector = length(var.node_selector) > 0 ? var.node_selector : null

            dynamic "toleration" {
              for_each = [for toleration in var.tolerations : toleration if toleration != null]

              content {
                key                = toleration.value.key
                operator           = toleration.value.operator
                value              = toleration.value.value
                effect             = toleration.value.effect
                toleration_seconds = toleration.value.toleration_seconds
              }
            }

            dynamic "security_context" {
              for_each = var.pod_security_context.seccomp_profile == null ? [] : [var.pod_security_context]

              content {
                seccomp_profile {
                  type              = security_context.value.seccomp_profile.type
                  localhost_profile = security_context.value.seccomp_profile.localhost_profile
                }
              }
            }

            dynamic "image_pull_secrets" {
              for_each = var.image_pull_secrets

              content {
                name = image_pull_secrets.value.name
              }
            }

            container {
              name              = "bitbucket-k8s-runner"
              image             = var.runner_image
              image_pull_policy = var.runner_image_pull_policy

              dynamic "security_context" {
                for_each = anytrue([for key, value in var.runner_security_context : value != null]) ? [var.runner_security_context] : []

                content {
                  privileged                 = security_context.value.privileged
                  allow_privilege_escalation = security_context.value.allow_privilege_escalation
                  read_only_root_filesystem  = security_context.value.read_only_root_filesystem
                  run_as_non_root            = security_context.value.run_as_non_root

                  dynamic "seccomp_profile" {
                    for_each = security_context.value.seccomp_profile == null ? [] : [security_context.value.seccomp_profile]

                    content {
                      type              = seccomp_profile.value.type
                      localhost_profile = seccomp_profile.value.localhost_profile
                    }
                  }
                }
              }

              dynamic "resources" {
                for_each = length(var.runner_resources.requests) > 0 || length(var.runner_resources.limits) > 0 ? [var.runner_resources] : []

                content {
                  requests = length(resources.value.requests) > 0 ? resources.value.requests : null
                  limits   = length(resources.value.limits) > 0 ? resources.value.limits : null
                }
              }

              env {
                name  = "ACCOUNT_UUID"
                value = "{${var.accountUuid}}"
              }

              env {
                name  = "RUNNER_UUID"
                value = "{${var.runnerUuid}}"
              }

              env {
                name = "OAUTH_CLIENT_ID"
                value_from {
                  secret_key_ref {
                    name = "runner-oauth-credentials"
                    key  = "oauthClientId"
                  }
                }
              }

              env {
                name = "OAUTH_CLIENT_SECRET"
                value_from {
                  secret_key_ref {
                    name = "runner-oauth-credentials"
                    key  = "oauthClientSecret"
                  }
                }
              }

              env {
                name  = "WORKING_DIRECTORY"
                value = "/tmp"
              }

              volume_mount {
                name       = "tmp"
                mount_path = "/tmp"
              }

              volume_mount {
                name       = "docker-containers"
                mount_path = "/var/lib/docker/containers"
                read_only  = true
              }

              volume_mount {
                name       = "var-run"
                mount_path = "/var/run"
              }
            }

            container {
              name              = "docker-in-docker"
              image             = var.dind_image
              image_pull_policy = var.dind_image_pull_policy

              dynamic "resources" {
                for_each = length(var.dind_resources.requests) > 0 || length(var.dind_resources.limits) > 0 ? [var.dind_resources] : []

                content {
                  requests = length(resources.value.requests) > 0 ? resources.value.requests : null
                  limits   = length(resources.value.limits) > 0 ? resources.value.limits : null
                }
              }

              security_context {
                privileged                 = var.dind_security_context.privileged
                allow_privilege_escalation = var.dind_security_context.allow_privilege_escalation
                read_only_root_filesystem  = var.dind_security_context.read_only_root_filesystem
                run_as_non_root            = var.dind_security_context.run_as_non_root

                dynamic "seccomp_profile" {
                  for_each = var.dind_security_context.seccomp_profile == null ? [] : [var.dind_security_context.seccomp_profile]

                  content {
                    type              = seccomp_profile.value.type
                    localhost_profile = seccomp_profile.value.localhost_profile
                  }
                }
              }

              volume_mount {
                name       = "tmp"
                mount_path = "/tmp"
              }

              volume_mount {
                name       = "docker-containers"
                mount_path = "/var/lib/docker/containers"
              }

              volume_mount {
                name       = "var-run"
                mount_path = "/var/run"
              }
            }

            restart_policy = "OnFailure"

            volume {
              name = "tmp"
            }

            volume {
              name = "docker-containers"
            }

            volume {
              name = "var-run"
            }
          }
        }

        backoff_limit = 6
        completions   = 1
        parallelism   = 1
      }
    }
  }

  depends_on = [
    kubernetes_secret.runner
  ]
}
