# Feature Specification: Add imagePullSecrets Support

**Feature Branch**: `001-add-imagepullsecrets`  
**Created**: 2026-05-18  
**Status**: Draft  
**Input**: Jira DMVP-10068 - Add imagePullSecrets support to Bitbucket runner module

## User Scenarios & Testing *(mandatory)*

### User Story 1 - Configure Image Pull Secrets (Priority: P1)

As a consumer of the Bitbucket runner module or repository root wrapper, I can provide image pull secret names so the runner workload can pull container images in clusters that require registry authentication.

**Why this priority**: This is the core requested capability and unblocks use of the runner module in authenticated registry, registry mirror, and cluster-standard private registry environments.

**Independent Test**: Configure the root wrapper or runner module with one or more image pull secret names and inspect the planned runner CronJob workload to confirm the same names are present on the pod template.

**Acceptance Scenarios**:

1. **Given** a root module consumer provides `image_pull_secrets = [{ name = "regcred" }]`, **When** the module is planned, **Then** the runner CronJob pod template includes an image pull secret named `regcred`.
2. **Given** a runner module consumer provides multiple image pull secret names, **When** the module is planned, **Then** each configured name is represented in the runner CronJob pod template.

---

### User Story 4 - Configure Created Namespace Labels (Priority: P2)

As a module consumer, I can provide labels for the runner namespace when the module creates that namespace, so the namespace can follow cluster labeling policies.

**Why this priority**: Namespace labels are part of the requested runner module configurability and are needed by clusters that rely on labels for policy, ownership, or discovery.

**Independent Test**: Configure namespace labels and inspect the planned namespace resource to confirm the labels are present.

**Acceptance Scenarios**:

1. **Given** a root module consumer provides `namespace_labels = { "app.kubernetes.io/name" = "bitbucket-runner" }`, **When** the module is planned with namespace creation enabled, **Then** the runner namespace metadata includes that label.
2. **Given** a module consumer omits namespace labels, **When** the module is planned, **Then** namespace label behavior remains empty by default.

---

### User Story 2 - Preserve Existing Default Behavior (Priority: P2)

As an existing module consumer, I can continue using the runner module without configuring image pull secrets and see no change to the generated workload.

**Why this priority**: Backward compatibility is required so the new input does not force changes on existing consumers.

**Independent Test**: Plan the runner module without image pull secrets and confirm no image pull secret entries are rendered.

**Acceptance Scenarios**:

1. **Given** a runner module consumer does not set image pull secrets, **When** the module is planned, **Then** the runner CronJob pod template does not include image pull secret entries.

---

### User Story 3 - Discover The New Input From Module Docs (Priority: P3)

As a module consumer, I can find the new image pull secret input in the runner module documentation and understand the expected value shape.

**Why this priority**: Documentation is necessary for adoption, but the runtime capability is the primary deliverable.

**Independent Test**: Review the runner module README and examples/tests to confirm the new input is documented with its default and expected usage shape.

**Acceptance Scenarios**:

1. **Given** a module consumer reads the runner module README, **When** they look at inputs, **Then** they can see the image pull secret input, type, default, and description.
2. **Given** a reviewer inspects test/example coverage, **When** they look for image pull secret usage, **Then** there is a relevant scenario showing the expected input shape.

### Edge Cases

- Empty image pull secret configuration must preserve current generated workload behavior.
- Empty namespace label configuration must preserve current namespace behavior except for rendering an empty labels map if the provider normalizes it.
- Multiple image pull secret names must render deterministically without dropping or renaming entries.
- The change must stay scoped to the root wrapper and runner module and must not affect the Bitbucket deployments module.

## Requirements *(mandatory)*

### Functional Requirements

- **FR-001**: The root wrapper and runner module MUST expose an optional input for image pull secret names.
- **FR-002**: The image pull secret input MUST default to an empty collection so existing consumers do not need to change configuration.
- **FR-003**: When one or more image pull secret names are provided, the runner workload MUST include matching pod-level image pull secret entries.
- **FR-004**: When no image pull secret names are provided, the runner workload MUST not render any image pull secret entries.
- **FR-005**: The root and runner module documentation MUST describe the image pull secret input, including type, default, and purpose.
- **FR-006**: The implementation MUST include validation evidence through the repository's existing runner module test or example workflow.
- **FR-007**: The implementation MUST pass the root wrapper input through to `modules/runner`.
- **FR-008**: The root wrapper and runner module MUST expose optional namespace labels for the namespace resource created by the runner module.
- **FR-009**: Namespace labels MUST default to an empty map.
- **FR-010**: The implementation MUST remain scoped to the root wrapper and `modules/runner` and must not change unrelated deployment module behavior.

### Key Entities

- **Image Pull Secret Name**: A Kubernetes secret name supplied by a module consumer to allow the runner workload to pull container images from authenticated registries or mirrors.
- **Runner Workload**: The Kubernetes CronJob pod template created by the runner module.

## Success Criteria *(mandatory)*

### Measurable Outcomes

- **SC-001**: A consumer can configure at least one image pull secret and see the same secret name represented in the planned runner workload.
- **SC-002**: A consumer who omits image pull secrets can plan the module without changing existing input configuration.
- **SC-003**: Documentation clearly exposes the new input with an empty default and example-compatible value shape.
- **SC-004**: Validation demonstrates both configured and default behaviors for the runner module.

## Assumptions

- The requested input shape is a list of Kubernetes secret reference objects, for example `image_pull_secrets = [{ name = "regcred" }]`.
- The image pull secrets apply at pod-template scope for the runner CronJob workload.
- Consumers are responsible for creating the referenced Kubernetes secrets in the target namespace.
- No changes are requested for the hardcoded runner or Docker-in-Docker image values.
- Root module consumers use the same `image_pull_secrets = [{ name = "regcred" }]` input shape as direct `modules/runner` consumers.
- Namespace labels use `namespace_labels = { key = "value" }` and apply only to the namespace resource when `create_namespace` is enabled.
