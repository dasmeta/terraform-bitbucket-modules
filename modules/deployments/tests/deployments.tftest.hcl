# Run from modules/deployments with Terraform >= 1.7; no Bitbucket API calls.
mock_provider "bitbucket" {}

run "deployment_environments_and_variables" {
  command = plan

  variables {
    repository_id = "example-workspace/example-repository"
    deployments = [
      {
        name  = "development"
        stage = "Test"
        variables = [
          { name = "API_URL", value = "https://development.example.com", secured = false },
          { name = "DEPLOY_TOKEN", value = "example-token", secured = true }
        ]
      },
      {
        name  = "production"
        stage = "Production"
        variables = [
          { name = "API_URL", value = "https://api.example.com", secured = false }
        ]
      }
    ]
  }

  assert {
    condition = (
      length(bitbucket_deployment.depl) == 2 &&
      bitbucket_deployment.depl["development"].repository == var.repository_id &&
      bitbucket_deployment.depl["development"].name == "development" &&
      bitbucket_deployment.depl["development"].stage == "Test" &&
      bitbucket_deployment.depl["production"].repository == var.repository_id &&
      bitbucket_deployment.depl["production"].name == "production" &&
      bitbucket_deployment.depl["production"].stage == "Production"
    )
    error_message = "Every deployment must retain its repository, unique name, and stage."
  }

  assert {
    condition = (
      length(bitbucket_deployment_variable.depl-vars) == 3 &&
      bitbucket_deployment_variable.depl-vars["development-API_URL"].key == "API_URL" &&
      bitbucket_deployment_variable.depl-vars["development-API_URL"].value == "https://development.example.com" &&
      !bitbucket_deployment_variable.depl-vars["development-API_URL"].secured &&
      bitbucket_deployment_variable.depl-vars["development-DEPLOY_TOKEN"].key == "DEPLOY_TOKEN" &&
      bitbucket_deployment_variable.depl-vars["development-DEPLOY_TOKEN"].value == "example-token" &&
      bitbucket_deployment_variable.depl-vars["development-DEPLOY_TOKEN"].secured &&
      bitbucket_deployment_variable.depl-vars["production-API_URL"].key == "API_URL" &&
      bitbucket_deployment_variable.depl-vars["production-API_URL"].value == "https://api.example.com" &&
      !bitbucket_deployment_variable.depl-vars["production-API_URL"].secured
    )
    error_message = "Deployment variables must preserve their keys, values, and secured flags."
  }
}

run "empty_deployments" {
  command = plan

  variables {
    repository_id = "example-workspace/example-repository"
    deployments   = []
  }

  assert {
    condition     = length(bitbucket_deployment.depl) == 0 && length(bitbucket_deployment_variable.depl-vars) == 0
    error_message = "An empty deployments list must create no environments or variables."
  }
}
