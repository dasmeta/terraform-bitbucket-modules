module "test" {
  source            = "../"
  oauthClientId     = "Outh Client ID"
  oauthClientSecret = "Outh Client Secret"
  accountUuid       = "Account Uuid"
  runnerUuid        = "Runner Uuid"
  namespace_labels = {
    "app.kubernetes.io/name" = "bitbucket-runner"
  }
  image_pull_secrets = [
    {
      name = "docker-registry-auth"
    }
  ]
}
