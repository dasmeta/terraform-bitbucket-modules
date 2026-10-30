# Plan-only resources checks; no cluster API calls. Terraform >=1.7 for mocks.
# Unset resource maps are computed by the provider/API, so assert configured values
# and omitted container blocks rather than predicting admission defaults.
mock_provider "kubernetes" {}

variables {
  oauthClientId     = "example-client"
  oauthClientSecret = "example-secret"
  accountUuid       = "example-account"
  runnerUuid        = "example-runner"
}

run "root_resources" {
  command = plan
  variables {
    runner_resources = { "requests" : { "cpu" : "250m", "memory" : "512Mi" }, "limits" : { "memory" : "1Gi" } }
    dind_resources   = { "requests" : { "cpu" : "500m", "memory" : "1Gi" }, "limits" : { "cpu" : "2", "memory" : "4Gi" } }
  }
}

run "omitted_resources" {
  command = plan
  module {
    source = "./modules/runner"
  }
  assert {
    condition     = length(kubernetes_cron_job_v1.runner_cronjob.spec[0].job_template[0].spec[0].template[0].spec[0].container[0].resources) == 0 && length(kubernetes_cron_job_v1.runner_cronjob.spec[0].job_template[0].spec[0].template[0].spec[0].container[1].resources) == 0
    error_message = "Resources must render on the matching container with omitted settings preserved."
  }
}

run "both_containers" {
  command = plan
  module {
    source = "./modules/runner"
  }
  variables {
    runner_resources = { "requests" : { "cpu" : "250m", "memory" : "512Mi" }, "limits" : { "memory" : "1Gi" } }
    dind_resources   = { "requests" : { "cpu" : "500m", "memory" : "1Gi", "ephemeral-storage" : "2Gi" }, "limits" : { "cpu" : "2", "memory" : "4Gi" } }
  }
  assert {
    condition     = kubernetes_cron_job_v1.runner_cronjob.spec[0].job_template[0].spec[0].template[0].spec[0].container[0].resources[0].requests["cpu"] == "250m" && kubernetes_cron_job_v1.runner_cronjob.spec[0].job_template[0].spec[0].template[0].spec[0].container[0].resources[0].requests["memory"] == "512Mi" && kubernetes_cron_job_v1.runner_cronjob.spec[0].job_template[0].spec[0].template[0].spec[0].container[0].resources[0].limits["memory"] == "1Gi" && kubernetes_cron_job_v1.runner_cronjob.spec[0].job_template[0].spec[0].template[0].spec[0].container[1].resources[0].requests["cpu"] == "500m" && kubernetes_cron_job_v1.runner_cronjob.spec[0].job_template[0].spec[0].template[0].spec[0].container[1].resources[0].requests["memory"] == "1Gi" && kubernetes_cron_job_v1.runner_cronjob.spec[0].job_template[0].spec[0].template[0].spec[0].container[1].resources[0].requests["ephemeral-storage"] == "2Gi" && kubernetes_cron_job_v1.runner_cronjob.spec[0].job_template[0].spec[0].template[0].spec[0].container[1].resources[0].limits["cpu"] == "2" && kubernetes_cron_job_v1.runner_cronjob.spec[0].job_template[0].spec[0].template[0].spec[0].container[1].resources[0].limits["memory"] == "4Gi"
    error_message = "Resources must render on the matching container with omitted settings preserved."
  }
}

run "runner_requests_only" {
  command = plan
  module {
    source = "./modules/runner"
  }
  variables {
    runner_resources = { "requests" : { "cpu" : "100m" } }
  }
  assert {
    condition     = kubernetes_cron_job_v1.runner_cronjob.spec[0].job_template[0].spec[0].template[0].spec[0].container[0].resources[0].requests["cpu"] == "100m" && length(kubernetes_cron_job_v1.runner_cronjob.spec[0].job_template[0].spec[0].template[0].spec[0].container[1].resources) == 0
    error_message = "Resources must render on the matching container with omitted settings preserved."
  }
}

run "dind_limits_only" {
  command = plan
  module {
    source = "./modules/runner"
  }
  variables {
    dind_resources = { "limits" : { "memory" : "2Gi" } }
  }
  assert {
    condition     = length(kubernetes_cron_job_v1.runner_cronjob.spec[0].job_template[0].spec[0].template[0].spec[0].container[0].resources) == 0 && kubernetes_cron_job_v1.runner_cronjob.spec[0].job_template[0].spec[0].template[0].spec[0].container[1].resources[0].limits["memory"] == "2Gi"
    error_message = "Resources must render on the matching container with omitted settings preserved."
  }
}

run "empty_resources" {
  command = plan
  module {
    source = "./modules/runner"
  }
  variables {
    runner_resources = {}
    dind_resources   = { "requests" : {}, "limits" : {} }
  }
  assert {
    condition     = length(kubernetes_cron_job_v1.runner_cronjob.spec[0].job_template[0].spec[0].template[0].spec[0].container[0].resources) == 0 && length(kubernetes_cron_job_v1.runner_cronjob.spec[0].job_template[0].spec[0].template[0].spec[0].container[1].resources) == 0
    error_message = "Resources must render on the matching container with omitted settings preserved."
  }
}

run "null_objects" {
  command = plan
  module {
    source = "./modules/runner"
  }
  variables {
    runner_resources = null
    dind_resources   = null
  }
  assert {
    condition     = length(kubernetes_cron_job_v1.runner_cronjob.spec[0].job_template[0].spec[0].template[0].spec[0].container[0].resources) == 0 && length(kubernetes_cron_job_v1.runner_cronjob.spec[0].job_template[0].spec[0].template[0].spec[0].container[1].resources) == 0
    error_message = "Resources must render on the matching container with omitted settings preserved."
  }
}

run "null_maps" {
  command = plan
  module {
    source = "./modules/runner"
  }
  variables {
    runner_resources = { "requests" : null, "limits" : null }
    dind_resources   = { "requests" : null, "limits" : { "memory" : "2Gi" } }
  }
  assert {
    condition     = length(kubernetes_cron_job_v1.runner_cronjob.spec[0].job_template[0].spec[0].template[0].spec[0].container[0].resources) == 0 && kubernetes_cron_job_v1.runner_cronjob.spec[0].job_template[0].spec[0].template[0].spec[0].container[1].resources[0].limits["memory"] == "2Gi"
    error_message = "Resources must render on the matching container with omitted settings preserved."
  }
}

run "blank_quantity_rejected" {
  command = plan
  module {
    source = "./modules/runner"
  }
  variables {
    runner_resources = { "requests" : { "cpu" : "  " } }
  }
  expect_failures = [var.runner_resources]
}

run "null_quantity_rejected" {
  command = plan
  module {
    source = "./modules/runner"
  }
  variables {
    dind_resources = { "limits" : { "memory" : null } }
  }
  expect_failures = [var.dind_resources]
}
