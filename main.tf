module "runner" {
  source            = "./modules/runner/"
  oauthClientId     = var.oauthClientId
  oauthClientSecret = var.oauthClientSecret
  accountUuid       = var.accountUuid
  runnerUuid        = var.runnerUuid

  namespace        = var.namespace
  create_namespace = var.create_namespace
}
