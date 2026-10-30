# Seccomp and pull-policy plan tests; no Kubernetes API calls.
mock_provider "kubernetes" {}
variables {
  oauthClientId     = "example-client"
  oauthClientSecret = "example-secret"
  accountUuid       = "example-account"
  runnerUuid        = "example-runner"
}

run "root_manifest_settings" {
  command = plan
  variables {
    runner_image_pull_policy = "Always"
    dind_image_pull_policy   = "IfNotPresent"
    runner_security_context  = { "seccomp_profile" : { "type" : "Unconfined" } }
    pod_security_context     = { "seccomp_profile" : { "type" : "Unconfined" } }
  }
}

run "live_profiles_and_policies" {
  command = plan
  module {
    source = "./modules/runner"
  }
  variables {
    runner_image_pull_policy = "Always"
    dind_image_pull_policy   = "IfNotPresent"
    runner_security_context  = { "seccomp_profile" : { "type" : "Unconfined" } }
    pod_security_context     = { "seccomp_profile" : { "type" : "Unconfined" } }
  }
  assert {
    condition     = kubernetes_cron_job_v1.runner_cronjob.spec[0].job_template[0].spec[0].template[0].spec[0].container[0].image_pull_policy == "Always" && kubernetes_cron_job_v1.runner_cronjob.spec[0].job_template[0].spec[0].template[0].spec[0].container[1].image_pull_policy == "IfNotPresent" && kubernetes_cron_job_v1.runner_cronjob.spec[0].job_template[0].spec[0].template[0].spec[0].container[0].security_context[0].seccomp_profile[0].type == "Unconfined" && kubernetes_cron_job_v1.runner_cronjob.spec[0].job_template[0].spec[0].template[0].spec[0].security_context[0].seccomp_profile[0].type == "Unconfined"
    error_message = "Manifest seccomp/pull settings must render at correct levels and preserve defaults."
  }
}

run "no_new_defaults" {
  command = plan
  module {
    source = "./modules/runner"
  }
  assert {
    condition     = length(kubernetes_cron_job_v1.runner_cronjob.spec[0].job_template[0].spec[0].template[0].spec[0].container[0].security_context) == 0 && length(kubernetes_cron_job_v1.runner_cronjob.spec[0].job_template[0].spec[0].template[0].spec[0].container[1].security_context[0].seccomp_profile) == 0 && length(kubernetes_cron_job_v1.runner_cronjob.spec[0].job_template[0].spec[0].template[0].spec[0].security_context) == 0
    error_message = "Manifest seccomp/pull settings must render at correct levels and preserve defaults."
  }
}

run "all_profile_levels" {
  command = plan
  module {
    source = "./modules/runner"
  }
  variables {
    runner_security_context = { "privileged" : false, "seccomp_profile" : { "type" : "RuntimeDefault" } }
    dind_security_context   = { "seccomp_profile" : { "type" : "Localhost", "localhost_profile" : "profiles/dind.json" } }
    pod_security_context    = { "seccomp_profile" : { "type" : "Unconfined" } }
  }
  assert {
    condition     = !kubernetes_cron_job_v1.runner_cronjob.spec[0].job_template[0].spec[0].template[0].spec[0].container[0].security_context[0].privileged && kubernetes_cron_job_v1.runner_cronjob.spec[0].job_template[0].spec[0].template[0].spec[0].container[0].security_context[0].seccomp_profile[0].type == "RuntimeDefault" && kubernetes_cron_job_v1.runner_cronjob.spec[0].job_template[0].spec[0].template[0].spec[0].container[1].security_context[0].privileged && kubernetes_cron_job_v1.runner_cronjob.spec[0].job_template[0].spec[0].template[0].spec[0].container[1].security_context[0].seccomp_profile[0].type == "Localhost" && kubernetes_cron_job_v1.runner_cronjob.spec[0].job_template[0].spec[0].template[0].spec[0].container[1].security_context[0].seccomp_profile[0].localhost_profile == "profiles/dind.json" && kubernetes_cron_job_v1.runner_cronjob.spec[0].job_template[0].spec[0].template[0].spec[0].security_context[0].seccomp_profile[0].type == "Unconfined"
    error_message = "Manifest seccomp/pull settings must render at correct levels and preserve defaults."
  }
}

run "null_new_settings" {
  command = plan
  module {
    source = "./modules/runner"
  }
  variables {
    runner_image_pull_policy = null
    dind_image_pull_policy   = null
    runner_security_context  = { "seccomp_profile" : null }
    pod_security_context     = null
  }
  assert {
    condition     = length(kubernetes_cron_job_v1.runner_cronjob.spec[0].job_template[0].spec[0].template[0].spec[0].container[0].security_context) == 0 && length(kubernetes_cron_job_v1.runner_cronjob.spec[0].job_template[0].spec[0].template[0].spec[0].security_context) == 0
    error_message = "Manifest seccomp/pull settings must render at correct levels and preserve defaults."
  }
}

run "invalid_pull_policy" {
  command = plan
  module {
    source = "./modules/runner"
  }
  variables {
    runner_image_pull_policy = "Sometimes"
  }
  expect_failures = [var.runner_image_pull_policy]
}

run "invalid_dind_policy" {
  command = plan
  module {
    source = "./modules/runner"
  }
  variables {
    dind_image_pull_policy = "sometimes"
  }
  expect_failures = [var.dind_image_pull_policy]
}

run "invalid_runner_profile" {
  command = plan
  module {
    source = "./modules/runner"
  }
  variables {
    runner_security_context = { "seccomp_profile" : { "type" : "Invalid" } }
  }
  expect_failures = [var.runner_security_context]
}

run "invalid_pod_profile" {
  command = plan
  module {
    source = "./modules/runner"
  }
  variables {
    pod_security_context = { "seccomp_profile" : { "type" : "Invalid" } }
  }
  expect_failures = [var.pod_security_context]
}

run "localhost_requires_path" {
  command = plan
  module {
    source = "./modules/runner"
  }
  variables {
    dind_security_context = { "seccomp_profile" : { "type" : "Localhost" } }
  }
  expect_failures = [var.dind_security_context]
}

run "nonlocal_rejects_path" {
  command = plan
  module {
    source = "./modules/runner"
  }
  variables {
    runner_security_context = { "seccomp_profile" : { "type" : "RuntimeDefault", "localhost_profile" : "profiles/x.json" } }
  }
  expect_failures = [var.runner_security_context]
}
