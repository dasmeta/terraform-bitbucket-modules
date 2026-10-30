# Container security-context plan tests; no Kubernetes API calls.
mock_provider "kubernetes" {}
variables {
  oauthClientId     = "example-client"
  oauthClientSecret = "example-secret"
  accountUuid       = "example-account"
  runnerUuid        = "example-runner"
}

run "root_security_context" {
  command = plan
  variables {
    runner_security_context = { "privileged" : false, "allow_privilege_escalation" : false, "read_only_root_filesystem" : true, "run_as_non_root" : true }
    dind_security_context   = { "privileged" : true, "allow_privilege_escalation" : true, "read_only_root_filesystem" : false, "run_as_non_root" : false }
  }
}

run "defaults" {
  command = plan
  module {
    source = "./modules/runner"
  }
  assert {
    condition     = length(kubernetes_cron_job_v1.runner_cronjob.spec[0].job_template[0].spec[0].template[0].spec[0].container[0].security_context) == 0 && kubernetes_cron_job_v1.runner_cronjob.spec[0].job_template[0].spec[0].template[0].spec[0].container[1].security_context[0].privileged
    error_message = "Security contexts must preserve defaults and explicit booleans on the matching containers."
  }
}

run "distinct_contexts" {
  command = plan
  module {
    source = "./modules/runner"
  }
  variables {
    runner_security_context = { "privileged" : false, "allow_privilege_escalation" : false, "read_only_root_filesystem" : true, "run_as_non_root" : true }
    dind_security_context   = { "privileged" : true, "allow_privilege_escalation" : true, "read_only_root_filesystem" : false, "run_as_non_root" : false }
  }
  assert {
    condition     = kubernetes_cron_job_v1.runner_cronjob.spec[0].job_template[0].spec[0].template[0].spec[0].container[0].security_context[0].privileged == false && kubernetes_cron_job_v1.runner_cronjob.spec[0].job_template[0].spec[0].template[0].spec[0].container[0].security_context[0].allow_privilege_escalation == false && kubernetes_cron_job_v1.runner_cronjob.spec[0].job_template[0].spec[0].template[0].spec[0].container[0].security_context[0].read_only_root_filesystem == true && kubernetes_cron_job_v1.runner_cronjob.spec[0].job_template[0].spec[0].template[0].spec[0].container[0].security_context[0].run_as_non_root == true && kubernetes_cron_job_v1.runner_cronjob.spec[0].job_template[0].spec[0].template[0].spec[0].container[1].security_context[0].privileged == true && kubernetes_cron_job_v1.runner_cronjob.spec[0].job_template[0].spec[0].template[0].spec[0].container[1].security_context[0].allow_privilege_escalation == true && kubernetes_cron_job_v1.runner_cronjob.spec[0].job_template[0].spec[0].template[0].spec[0].container[1].security_context[0].read_only_root_filesystem == false && kubernetes_cron_job_v1.runner_cronjob.spec[0].job_template[0].spec[0].template[0].spec[0].container[1].security_context[0].run_as_non_root == false
    error_message = "Security contexts must preserve defaults and explicit booleans on the matching containers."
  }
}

run "false_privileged_override" {
  command = plan
  module {
    source = "./modules/runner"
  }
  variables {
    dind_security_context = { "privileged" : false, "allow_privilege_escalation" : false, "read_only_root_filesystem" : false, "run_as_non_root" : false }
  }
  assert {
    condition     = length(kubernetes_cron_job_v1.runner_cronjob.spec[0].job_template[0].spec[0].template[0].spec[0].container[0].security_context) == 0 && !kubernetes_cron_job_v1.runner_cronjob.spec[0].job_template[0].spec[0].template[0].spec[0].container[1].security_context[0].privileged && !kubernetes_cron_job_v1.runner_cronjob.spec[0].job_template[0].spec[0].template[0].spec[0].container[1].security_context[0].allow_privilege_escalation && !kubernetes_cron_job_v1.runner_cronjob.spec[0].job_template[0].spec[0].template[0].spec[0].container[1].security_context[0].read_only_root_filesystem && !kubernetes_cron_job_v1.runner_cronjob.spec[0].job_template[0].spec[0].template[0].spec[0].container[1].security_context[0].run_as_non_root
    error_message = "Security contexts must preserve defaults and explicit booleans on the matching containers."
  }
}

run "runner_partial_false" {
  command = plan
  module {
    source = "./modules/runner"
  }
  variables {
    runner_security_context = { "privileged" : false }
  }
  assert {
    condition     = length(kubernetes_cron_job_v1.runner_cronjob.spec[0].job_template[0].spec[0].template[0].spec[0].container[0].security_context) == 1 && !kubernetes_cron_job_v1.runner_cronjob.spec[0].job_template[0].spec[0].template[0].spec[0].container[0].security_context[0].privileged && kubernetes_cron_job_v1.runner_cronjob.spec[0].job_template[0].spec[0].template[0].spec[0].container[1].security_context[0].privileged
    error_message = "Security contexts must preserve defaults and explicit booleans on the matching containers."
  }
}

run "empty_objects" {
  command = plan
  module {
    source = "./modules/runner"
  }
  variables {
    runner_security_context = {}
    dind_security_context   = {}
  }
  assert {
    condition     = length(kubernetes_cron_job_v1.runner_cronjob.spec[0].job_template[0].spec[0].template[0].spec[0].container[0].security_context) == 0 && kubernetes_cron_job_v1.runner_cronjob.spec[0].job_template[0].spec[0].template[0].spec[0].container[1].security_context[0].privileged
    error_message = "Security contexts must preserve defaults and explicit booleans on the matching containers."
  }
}

run "null_objects" {
  command = plan
  module {
    source = "./modules/runner"
  }
  variables {
    runner_security_context = null
    dind_security_context   = null
  }
  assert {
    condition     = length(kubernetes_cron_job_v1.runner_cronjob.spec[0].job_template[0].spec[0].template[0].spec[0].container[0].security_context) == 0 && kubernetes_cron_job_v1.runner_cronjob.spec[0].job_template[0].spec[0].template[0].spec[0].container[1].security_context[0].privileged
    error_message = "Security contexts must preserve defaults and explicit booleans on the matching containers."
  }
}

run "null_attributes" {
  command = plan
  module {
    source = "./modules/runner"
  }
  variables {
    runner_security_context = { "privileged" : null, "allow_privilege_escalation" : null, "read_only_root_filesystem" : null, "run_as_non_root" : null }
    dind_security_context   = { "privileged" : null, "allow_privilege_escalation" : null, "read_only_root_filesystem" : null, "run_as_non_root" : null }
  }
  assert {
    condition     = length(kubernetes_cron_job_v1.runner_cronjob.spec[0].job_template[0].spec[0].template[0].spec[0].container[0].security_context) == 0 && kubernetes_cron_job_v1.runner_cronjob.spec[0].job_template[0].spec[0].template[0].spec[0].container[1].security_context[0].privileged
    error_message = "Security contexts must preserve defaults and explicit booleans on the matching containers."
  }
}
