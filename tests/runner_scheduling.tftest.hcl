# Optional Pod scheduling plan tests; no cluster/API calls.
mock_provider "kubernetes" {}
variables {
  oauthClientId     = "example-client"
  oauthClientSecret = "example-secret"
  accountUuid       = "example-account"
  runnerUuid        = "example-runner"
}

run "root_regular_selector" {
  command = plan
  variables {
    node_selector = { "nodetype" : "regular" }
  }
}

run "selector_and_tolerations" {
  command = plan
  module {
    source = "./modules/runner"
  }
  variables {
    node_selector = { "nodetype" : "regular" }
    tolerations   = [{ "key" : "dedicated", "value" : "runner", "effect" : "NoSchedule" }, { "key" : "node.kubernetes.io/unreachable", "operator" : "Exists", "effect" : "NoExecute", "toleration_seconds" : 60 }]
  }
  assert {
    condition     = kubernetes_cron_job_v1.runner_cronjob.spec[0].job_template[0].spec[0].template[0].spec[0].node_selector["nodetype"] == "regular" && length(kubernetes_cron_job_v1.runner_cronjob.spec[0].job_template[0].spec[0].template[0].spec[0].toleration) == 2 && kubernetes_cron_job_v1.runner_cronjob.spec[0].job_template[0].spec[0].template[0].spec[0].toleration[0].key == "dedicated" && kubernetes_cron_job_v1.runner_cronjob.spec[0].job_template[0].spec[0].template[0].spec[0].toleration[0].operator == "Equal" && kubernetes_cron_job_v1.runner_cronjob.spec[0].job_template[0].spec[0].template[0].spec[0].toleration[0].value == "runner" && kubernetes_cron_job_v1.runner_cronjob.spec[0].job_template[0].spec[0].template[0].spec[0].toleration[0].effect == "NoSchedule" && kubernetes_cron_job_v1.runner_cronjob.spec[0].job_template[0].spec[0].template[0].spec[0].toleration[1].operator == "Exists" && kubernetes_cron_job_v1.runner_cronjob.spec[0].job_template[0].spec[0].template[0].spec[0].toleration[1].effect == "NoExecute" && tonumber(kubernetes_cron_job_v1.runner_cronjob.spec[0].job_template[0].spec[0].template[0].spec[0].toleration[1].toleration_seconds) == 60
    error_message = "Scheduling inputs must render on Pod spec and remain empty by default."
  }
}

run "wildcard_exists" {
  command = plan
  module {
    source = "./modules/runner"
  }
  variables {
    tolerations = [{ "operator" : "Exists", "effect" : "NoSchedule" }]
  }
  assert {
    condition     = length(kubernetes_cron_job_v1.runner_cronjob.spec[0].job_template[0].spec[0].template[0].spec[0].toleration) == 1 && kubernetes_cron_job_v1.runner_cronjob.spec[0].job_template[0].spec[0].template[0].spec[0].toleration[0].key == "" && kubernetes_cron_job_v1.runner_cronjob.spec[0].job_template[0].spec[0].template[0].spec[0].toleration[0].value == "" && kubernetes_cron_job_v1.runner_cronjob.spec[0].job_template[0].spec[0].template[0].spec[0].toleration[0].operator == "Exists"
    error_message = "Scheduling inputs must render on Pod spec and remain empty by default."
  }
}

run "no_scheduling_defaults" {
  command = plan
  module {
    source = "./modules/runner"
  }
  assert {
    condition     = length(coalesce(kubernetes_cron_job_v1.runner_cronjob.spec[0].job_template[0].spec[0].template[0].spec[0].node_selector, {})) == 0 && length(kubernetes_cron_job_v1.runner_cronjob.spec[0].job_template[0].spec[0].template[0].spec[0].toleration) == 0
    error_message = "Scheduling inputs must render on Pod spec and remain empty by default."
  }
}

run "null_scheduling_inputs" {
  command = plan
  module {
    source = "./modules/runner"
  }
  variables {
    node_selector = null
    tolerations   = null
  }
  assert {
    condition     = length(coalesce(kubernetes_cron_job_v1.runner_cronjob.spec[0].job_template[0].spec[0].template[0].spec[0].node_selector, {})) == 0 && length(kubernetes_cron_job_v1.runner_cronjob.spec[0].job_template[0].spec[0].template[0].spec[0].toleration) == 0
    error_message = "Scheduling inputs must render on Pod spec and remain empty by default."
  }
}

run "invalid_operator" {
  command = plan
  module {
    source = "./modules/runner"
  }
  variables {
    tolerations = [{ "key" : "dedicated", "operator" : "Other" }]
  }
  expect_failures = [var.tolerations]
}

run "exists_rejects_value" {
  command = plan
  module {
    source = "./modules/runner"
  }
  variables {
    tolerations = [{ "key" : "dedicated", "operator" : "Exists", "value" : "runner" }]
  }
  expect_failures = [var.tolerations]
}

run "invalid_seconds" {
  command = plan
  module {
    source = "./modules/runner"
  }
  variables {
    tolerations = [{ "key" : "dedicated", "effect" : "NoExecute", "toleration_seconds" : 0.5 }]
  }
  expect_failures = [var.tolerations]
}

run "null_selector_value" {
  command = plan
  module {
    source = "./modules/runner"
  }
  variables {
    node_selector = { "nodetype" : null }
  }
  expect_failures = [var.node_selector]
}
