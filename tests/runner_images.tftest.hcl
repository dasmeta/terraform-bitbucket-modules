# Run with Terraform >= 1.7. Provider mocks keep all checks off the cluster.
mock_provider "kubernetes" {}

variables {
  oauthClientId     = "example-client-id"
  oauthClientSecret = "example-client-secret"
  accountUuid       = "example-account"
  runnerUuid        = "example-runner"
}

# Root wrapper plans are also inspected with `terraform test -verbose`.
run "root_defaults" {
  command = plan
}

run "root_overrides" {
  command = plan

  variables {
    runner_image = "registry.example.com/runner:6.1.3"
    dind_image   = "registry.example.com/docker:29.9.2-dind"
  }
}

run "direct_defaults" {
  command = plan
  module {
    source = "./modules/runner"
  }

  assert {
    condition     = kubernetes_cron_job_v1.runner_cronjob.spec[0].job_template[0].spec[0].template[0].spec[0].container[0].image == "docker-public.packages.atlassian.com/sox/atlassian/bitbucket-pipelines-runner:6.1.3"
    error_message = "Runner must use the documented pinned default."
  }
  assert {
    condition     = kubernetes_cron_job_v1.runner_cronjob.spec[0].job_template[0].spec[0].template[0].spec[0].container[1].image == "docker:29.9.2-dind"
    error_message = "DinD must use the documented pinned default."
  }
}

run "direct_overrides" {
  command = plan
  module {
    source = "./modules/runner"
  }
  variables {
    runner_image = "registry.example.com/runner@sha256:705b4209d38bc84b1e928f781b4f1e622633eee8ad9bb78f74295a069182ae0b"
    dind_image   = "registry.example.com/docker:29.9.2-dind"
  }

  assert {
    condition     = kubernetes_cron_job_v1.runner_cronjob.spec[0].job_template[0].spec[0].template[0].spec[0].container[0].image == var.runner_image && kubernetes_cron_job_v1.runner_cronjob.spec[0].job_template[0].spec[0].template[0].spec[0].container[1].image == var.dind_image
    error_message = "Each custom image must reach its matching container unchanged."
  }
}

run "runner_only_override" {
  command = plan
  module {
    source = "./modules/runner"
  }
  variables {
    runner_image = "registry.example.com/runner:custom"
  }

  assert {
    condition     = kubernetes_cron_job_v1.runner_cronjob.spec[0].job_template[0].spec[0].template[0].spec[0].container[0].image == var.runner_image && kubernetes_cron_job_v1.runner_cronjob.spec[0].job_template[0].spec[0].template[0].spec[0].container[1].image == "docker:29.9.2-dind"
    error_message = "Overriding runner must retain the DinD default."
  }
}

run "dind_only_override" {
  command = plan
  module {
    source = "./modules/runner"
  }
  variables {
    dind_image = "registry.example.com/docker:custom-dind"
  }

  assert {
    condition     = kubernetes_cron_job_v1.runner_cronjob.spec[0].job_template[0].spec[0].template[0].spec[0].container[0].image == "docker-public.packages.atlassian.com/sox/atlassian/bitbucket-pipelines-runner:6.1.3" && kubernetes_cron_job_v1.runner_cronjob.spec[0].job_template[0].spec[0].template[0].spec[0].container[1].image == var.dind_image
    error_message = "Overriding DinD must retain the runner default."
  }
}

run "blank_runner_rejected" {
  command = plan
  module {
    source = "./modules/runner"
  }
  variables {
    runner_image = "  "
  }
  expect_failures = [var.runner_image]
}

run "empty_dind_rejected" {
  command = plan
  module {
    source = "./modules/runner"
  }
  variables {
    dind_image = ""
  }
  expect_failures = [var.dind_image]
}

run "null_uses_defaults" {
  command = plan
  module {
    source = "./modules/runner"
  }
  variables {
    runner_image = null
    dind_image   = null
  }

  assert {
    condition     = kubernetes_cron_job_v1.runner_cronjob.spec[0].job_template[0].spec[0].template[0].spec[0].container[0].image == "docker-public.packages.atlassian.com/sox/atlassian/bitbucket-pipelines-runner:6.1.3" && kubernetes_cron_job_v1.runner_cronjob.spec[0].job_template[0].spec[0].template[0].spec[0].container[1].image == "docker:29.9.2-dind"
    error_message = "Explicit null must select both defaults."
  }
}
