# Research: Add imagePullSecrets Support

## Decision: Use a `list(object({ name = string }))` input with an empty default

**Rationale**: The consumer-facing usage shape is `image_pull_secrets = [{ name = "regcred" }]`, matching Kubernetes `imagePullSecrets` object shape while still exposing only the required secret name field. This satisfies pod-level image pull secret configuration without exposing broad Kubernetes pod-spec pass-through fields.

**Alternatives considered**:

- List of strings: rejected because existing consumer configuration uses the Kubernetes-shaped `{ name = "..." }` object and Terraform rejects that value against `list(string)`.
- Generic pod-spec override input: rejected because it would widen the module interface beyond the requested common case.

## Decision: Render pod-level image pull secrets only when names are provided

**Rationale**: The acceptance criteria require no behavior change for existing consumers. A dynamic block driven by the input list keeps the generated CronJob unchanged for the empty default and emits one entry per configured name.

**Alternatives considered**:

- Always render an empty block: rejected because it could alter generated provider output or create unnecessary diffs.
- Container-level configuration: rejected because Kubernetes image pull secrets belong on the pod spec, not individual containers.

## Decision: Keep implementation scoped to the root wrapper and `modules/runner`

**Rationale**: The repository root module wraps `modules/runner`, so consumers of this module need the same `image_pull_secrets` input exposed at the root and passed through to the runner submodule. The change still excludes unrelated deployment module behavior.

**Alternatives considered**:

- Keep the input only in `modules/runner`: rejected because root module consumers could not use the new capability.

## Decision: Update README and runner test/example coverage

**Rationale**: The module already has generated-style README input tables and a basic test example. The new input must be visible to consumers and represented in validation evidence.

**Alternatives considered**:

- Code-only change: rejected because acceptance criteria require docs and relevant tests/examples.
