# Pod-template annotation plan tests; no API calls.
mock_provider "kubernetes" {}
variables {
  oauthClientId     = "example-client"
  oauthClientSecret = "example-secret"
  accountUuid       = "example-account"
  runnerUuid        = "example-runner"
}

run "root_pod_annotations" {
  command = plan
  variables {
    pod_annotations = { "karpenter.sh/do-not-disrupt" : "true", "example.com/purpose" : "runner" }
  }
}

run "direct_pod_annotations" {
  command = plan
  module {
    source = "./modules/runner"
  }
  variables {
    pod_annotations = { "karpenter.sh/do-not-disrupt" : "true", "example.com/purpose" : "runner" }
  }
  assert {
    condition     = kubernetes_cron_job_v1.runner_cronjob.spec[0].job_template[0].spec[0].template[0].metadata[0].annotations["karpenter.sh/do-not-disrupt"] == "true" && kubernetes_cron_job_v1.runner_cronjob.spec[0].job_template[0].spec[0].template[0].metadata[0].annotations["example.com/purpose"] == "runner" && kubernetes_cron_job_v1.runner_cronjob.spec[0].job_template[0].spec[0].template[0].metadata[0].labels["accountUuid"] == var.accountUuid && kubernetes_cron_job_v1.runner_cronjob.spec[0].job_template[0].spec[0].template[0].metadata[0].labels["runnerUuid"] == var.runnerUuid
    error_message = "Pod annotations must preserve values and existing labels at Pod template metadata."
  }
}

run "omitted_annotations" {
  command = plan
  module {
    source = "./modules/runner"
  }
  assert {
    condition     = length(kubernetes_cron_job_v1.runner_cronjob.spec[0].job_template[0].spec[0].template[0].metadata[0].annotations) == 0
    error_message = "Pod annotations must preserve values and existing labels at Pod template metadata."
  }
}

run "empty_annotations" {
  command = plan
  module {
    source = "./modules/runner"
  }
  variables {
    pod_annotations = {}
  }
  assert {
    condition     = length(kubernetes_cron_job_v1.runner_cronjob.spec[0].job_template[0].spec[0].template[0].metadata[0].annotations) == 0
    error_message = "Pod annotations must preserve values and existing labels at Pod template metadata."
  }
}

run "null_annotations" {
  command = plan
  module {
    source = "./modules/runner"
  }
  variables {
    pod_annotations = null
  }
  assert {
    condition     = length(kubernetes_cron_job_v1.runner_cronjob.spec[0].job_template[0].spec[0].template[0].metadata[0].annotations) == 0
    error_message = "Pod annotations must preserve values and existing labels at Pod template metadata."
  }
}

run "false_and_empty_values" {
  command = plan
  module {
    source = "./modules/runner"
  }
  variables {
    pod_annotations = { "karpenter.sh/do-not-disrupt" : "false", "example.com/empty" : "" }
  }
  assert {
    condition     = kubernetes_cron_job_v1.runner_cronjob.spec[0].job_template[0].spec[0].template[0].metadata[0].annotations["karpenter.sh/do-not-disrupt"] == "false" && kubernetes_cron_job_v1.runner_cronjob.spec[0].job_template[0].spec[0].template[0].metadata[0].annotations["example.com/empty"] == ""
    error_message = "Pod annotations must preserve values and existing labels at Pod template metadata."
  }
}

run "null_value_rejected" {
  command = plan
  module {
    source = "./modules/runner"
  }
  variables {
    pod_annotations = { "example.com/null" : null }
  }
  expect_failures = [var.pod_annotations]
}
