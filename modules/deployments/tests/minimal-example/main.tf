module "deployments" {
  source = "../.."

  repository_id = "example-workspace/example-repository"
  deployments = [
    {
      name      = "development"
      stage     = "Test"
      variables = []
    }
  ]
}
