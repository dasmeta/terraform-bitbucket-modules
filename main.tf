module "runner" {
  source                   = "./modules/runner/"
  oauthClientId            = var.oauthClientId
  oauthClientSecret        = var.oauthClientSecret
  accountUuid              = var.accountUuid
  runnerUuid               = var.runnerUuid
  runner_image             = var.runner_image
  dind_image               = var.dind_image
  runner_image_pull_policy = var.runner_image_pull_policy
  dind_image_pull_policy   = var.dind_image_pull_policy
  runner_resources         = var.runner_resources
  dind_resources           = var.dind_resources
  runner_security_context  = var.runner_security_context
  dind_security_context    = var.dind_security_context
  pod_security_context     = var.pod_security_context

  namespace          = var.namespace
  create_namespace   = var.create_namespace
  namespace_labels   = var.namespace_labels
  pod_annotations    = var.pod_annotations
  node_selector      = var.node_selector
  tolerations        = var.tolerations
  image_pull_secrets = var.image_pull_secrets
}
