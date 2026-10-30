# Tasks: Add imagePullSecrets Support

**Input**: Design documents from `/specs/001-add-imagepullsecrets/`
**Prerequisites**: plan.md, spec.md, research.md, data-model.md, contracts/, quickstart.md

**Tests**: Included because Jira acceptance criteria require relevant test/example coverage.

**Organization**: Tasks are grouped by user story to enable independent implementation and testing.

## Phase 1: Setup (Shared Infrastructure)

**Purpose**: Confirm the root wrapper and runner module baseline before behavior changes.

- [x] T001 Inspect current runner module input, root wrapper input, CronJob pod spec, and namespace resource in `variables.tf`, `main.tf`, `modules/runner/variables.tf`, `modules/runner/cronjob.tf`, and `modules/runner/namespace.tf`
- [x] T002 Inspect current runner module test/example/docs coverage in `modules/runner/tests/basic/1-example.tf`, `modules/runner/tests/basic/2-assert.tf`, and `modules/runner/README.md`

---

## Phase 2: Foundational (Blocking Prerequisites)

**Purpose**: Add the module input that all user stories depend on.

- [x] T003 Add optional `image_pull_secrets` list input with empty default in `modules/runner/variables.tf`
- [x] T003A Add optional `image_pull_secrets` list input with empty default in root `variables.tf`
- [x] T003B Pass root `var.image_pull_secrets` into the runner submodule in root `main.tf`
- [x] T003C Add optional `namespace_labels` map input with empty default in root and runner `variables.tf`
- [x] T003D Pass root `var.namespace_labels` into the runner submodule in root `main.tf`

**Checkpoint**: Shared input contract exists and user story implementation can proceed.

---

## Phase 3: User Story 1 - Configure Image Pull Secrets (Priority: P1) MVP

**Goal**: Consumers can provide image pull secret names and see them on the runner CronJob pod template.

**Independent Test**: Configure `image_pull_secrets = [{ name = "regcred" }]` in the runner module example/test and verify the rendered CronJob contains the matching pod-level image pull secret entry.

### Tests for User Story 1

- [x] T004 [P] [US1] Add configured image pull secret usage to `modules/runner/tests/basic/1-example.tf`
- [x] T005 [P] [US1] Add assertion coverage for configured image pull secret behavior in `modules/runner/tests/basic/2-assert.tf`

### Implementation for User Story 1

- [x] T006 [US1] Render dynamic pod-level `image_pull_secrets` blocks from `var.image_pull_secrets` in `modules/runner/cronjob.tf`
- [x] T006A [US1] Render namespace labels from `var.namespace_labels` in `modules/runner/namespace.tf`

**Checkpoint**: Configured image pull secret support is implemented and independently testable.

---

## Phase 4: User Story 2 - Preserve Existing Default Behavior (Priority: P2)

**Goal**: Existing consumers that omit the new input see no generated image pull secret entries.

**Independent Test**: Review the empty default and validation output to confirm the module remains usable without the new input.

### Tests for User Story 2

- [x] T007 [US2] Confirm default empty input behavior remains represented in `modules/runner/variables.tf` and validation does not require callers to set the input

### Implementation for User Story 2

- [x] T008 [US2] Verify `modules/runner/cronjob.tf` renders no `image_pull_secrets` blocks when `var.image_pull_secrets` is empty

**Checkpoint**: Backward compatibility is preserved.

---

## Phase 5: User Story 3 - Discover The New Input From Module Docs (Priority: P3)

**Goal**: Consumers can discover the new input and its value shape from documentation.

**Independent Test**: Review the runner README input table and examples/tests for the documented input shape.

### Implementation for User Story 3

- [x] T009 [US3] Update `modules/runner/README.md` and root `README.md` to document `image_pull_secrets` and `namespace_labels`
- [x] T010 [US3] Update `modules/runner/tests/basic/README.md` if generated docs or examples require the new input to appear there

**Checkpoint**: Documentation reflects the new input.

---

## Phase 6: Polish & Validation

**Purpose**: Format, validate, and record completion.

- [x] T011 Run `terraform fmt -recursive` for repository Terraform files
- [x] T012 Run available Terraform validation for `modules/runner`
- [x] T013 Review `git diff` to confirm changes are scoped to Speckit artifacts, root wrapper pass-through, and `modules/runner`

---

## Dependencies & Execution Order

### Phase Dependencies

- **Setup (Phase 1)**: No dependencies.
- **Foundational (Phase 2)**: Depends on Setup completion.
- **User Story 1 (Phase 3)**: Depends on Foundational completion.
- **User Story 2 (Phase 4)**: Depends on User Story 1 implementation for final behavior verification.
- **User Story 3 (Phase 5)**: Depends on finalized input name/type.
- **Polish (Phase 6)**: Depends on selected user stories being complete.

### User Story Dependencies

- **User Story 1 (P1)**: First deliverable; creates the core behavior.
- **User Story 2 (P2)**: Verifies compatibility after behavior exists.
- **User Story 3 (P3)**: Documents the finalized interface.

### Parallel Opportunities

- T004 and T005 can be prepared in parallel because they touch different files, but both must be reconciled before validation.

## Implementation Strategy

1. Complete setup and add the input contract.
2. Implement and validate configured `image_pull_secrets` rendering.
3. Verify empty default behavior.
4. Update documentation.
5. Run formatting and validation.
