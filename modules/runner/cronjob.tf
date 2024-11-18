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
            labels = {
              accountUuid = var.accountUuid
              runnerUuid  = var.runnerUuid
            }
          }

          spec {
            container {
              name  = "bitbucket-k8s-runner"
              image = "docker-public.packages.atlassian.com/sox/atlassian/bitbucket-pipelines-runner"

              env {
                name  = "ACCOUNT_UUID"
                value = var.accountUuid
              }

              env {
                name  = "RUNNER_UUID"
                value = var.runnerUuid
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
              name  = "docker-in-docker"
              image = "docker:20.10.7-dind"
              security_context {
                privileged = true
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
