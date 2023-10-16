resource "kubernetes_secret" "runner" {
  metadata {
    name = "runner-oauth-credentials"
    labels = {
      "accountUuid" = var.accountUuid
      "runnerUuid" : var.runnerUuid
    }
    namespace = var.namespace
  }

  data = {
    "oauthClientId"     = var.oauthClientId
    "oauthClientSecret" = var.oauthClientSecret
  }

  type = "Opaque"

  depends_on = [
    kubernetes_namespace_v1.runner
  ]
}
