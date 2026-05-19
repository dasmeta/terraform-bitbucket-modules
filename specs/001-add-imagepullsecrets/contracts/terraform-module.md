# Contract: Root and Runner Module Input

## Input

```hcl
image_pull_secrets = [
  {
    name = "regcred"
  }
]

namespace_labels = {
  "app.kubernetes.io/name" = "bitbucket-runner"
}
```

## Expected Behavior

- Type: list of objects with a `name` string field.
- Default: empty list.
- Scope: root module input passes through to the runner submodule and applies to the runner CronJob pod template.
- Rendering: one pod-level image pull secret entry per provided name.
- Backward compatibility: omitting the input must preserve existing generated workload behavior.
- Namespace labels type: map of strings.
- Namespace labels default: empty map.
- Namespace labels scope: root module input passes through to the runner submodule and applies to the created namespace metadata.

## Non-Goals

- Creating Kubernetes Secret resources.
- Changing runner container images.
- Changing the Bitbucket deployments module.
