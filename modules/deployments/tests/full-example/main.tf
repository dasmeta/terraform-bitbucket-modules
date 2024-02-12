module "bitbucket" {
  source = "../"

  name        = "Repository-terraformed"
  owner       = "DevOps"
  description = "Repository description"
  website     = "www.dasmeta.com"
  language    = "python"
  fork_policy = "allow_forks"

  project = {
    create     = true
    name       = "Project1"
    key        = "project1"
    is_private = false
  }

  restrictions = {
    action = "push"
    branch = "master"
  }

  deployments = [
    {
      name  = "development1"
      stage = "Test"
      variables = [
        { name = "key1", value = "value1", secured = true },
        { name = "key2", value = "value2", secured = false }
      ]
    },
    {
      name  = "development2"
      stage = "Test"
      variables = [
        { name = "key1", value = "value1", secured = true },
        { name = "key2", value = "value2", secured = false }
      ]
    },
  ]

  repository_variables = [
    { name = "key1", value = "value1", secured = true },
    { name = "key2", value = "value2", secured = false }
  ]
}
