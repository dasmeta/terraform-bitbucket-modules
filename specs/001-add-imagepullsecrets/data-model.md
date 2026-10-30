# Data Model: Add imagePullSecrets Support

## Entity: Image Pull Secret Name

**Purpose**: Represents a Kubernetes Secret name that the runner workload can use when pulling container images.

**Fields**:

- `name`: non-empty string, passed by the module consumer.

**Validation Rules**:

- The collection defaults to empty.
- Each provided value is rendered as a distinct pod-level image pull secret reference.
- Consumers are responsible for creating the referenced Secret in the runner namespace.

## Entity: Runner Workload

**Purpose**: The Kubernetes CronJob pod template created by the runner module.

**Fields affected by this feature**:

- `image_pull_secrets`: zero or more secret references on the pod spec.

**State Rules**:

- Empty input means no image pull secret entries are rendered.
- Non-empty input means all provided names are represented in the generated workload.
