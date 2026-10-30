module "test" {
  source                   = "../.."
  oauthClientId            = "Outh Client ID"
  oauthClientSecret        = "Outh Client Secret"
  accountUuid              = "Account Uuid"
  runnerUuid               = "Runner Uuid"
  runner_image             = "docker-public.packages.atlassian.com/sox/atlassian/bitbucket-pipelines-runner:6.1.3"
  dind_image               = "docker:29.9.2-dind"
  runner_image_pull_policy = "Always"
  dind_image_pull_policy   = "IfNotPresent"

  # Illustrative sizing; tune requests and limits for actual pipeline workloads.
  runner_resources = {
    requests = { cpu = "100m", memory = "256Mi" }
    limits   = { memory = "1Gi" }
  }
  dind_resources = {
    requests = { cpu = "500m", memory = "1Gi" }
    limits   = { memory = "4Gi" }
  }

  # Validate custom security flags with the selected images in staging.
  runner_security_context = {
    privileged                 = false
    allow_privilege_escalation = false
    seccomp_profile            = { type = "Unconfined" }
  }
  dind_security_context = {
    privileged                 = true
    allow_privilege_escalation = true
    read_only_root_filesystem  = false
    run_as_non_root            = false
  }
  # Explicit manifest parity; choose seccomp profiles for the target cluster.
  pod_security_context = {
    seccomp_profile = { type = "Unconfined" }
  }

  namespace_labels = {
    "app.kubernetes.io/name" = "bitbucket-runner"
  }
  # Controller-specific example: Karpenter voluntary disruption protection.
  pod_annotations = {
    "karpenter.sh/do-not-disrupt" = "true"
  }
  # This regular pool uses a label and has no taints requiring tolerations.
  node_selector = { nodetype = "regular" }
  tolerations   = []

  image_pull_secrets = [
    {
      name = "docker-registry-auth"
    }
  ]
}
