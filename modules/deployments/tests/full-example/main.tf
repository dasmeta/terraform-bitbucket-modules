module "deployments" {
  source = "../.."

  repository_id = "example-workspace/example-repository"
  deployments = [
    {
      name  = "development"
      stage = "Test"
      variables = [
        { name = "DEPLOY_TOKEN", value = "example-development-token", secured = true },
        { name = "API_URL", value = "https://development.example.com", secured = false }
      ]
    },
    {
      name  = "production"
      stage = "Production"
      variables = [
        { name = "DEPLOY_TOKEN", value = "example-production-token", secured = true },
        { name = "API_URL", value = "https://api.example.com", secured = false }
      ]
    }
  ]
}
