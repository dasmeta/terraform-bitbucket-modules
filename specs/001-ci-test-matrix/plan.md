# CI deployment-test plan

**Date**:2026-10-30 | **Spec**:[spec.md](spec.md)

## Baseline and scope

Working tree was clean. Existing terraform-test workflow runs a legacy composite action with path=/ and continue-on-error=true. Deployment mocks live under modules/deployments/tests and require their own working directory. The AGENTS plan reference specs/001-add-imagepullsecrets/plan.md is absent; this bounded package records the current change instead.

## Design

Replace only terraform-test.yaml's composite step with checkout, setup-terraform and direct init/validate/test commands. Matrix paths are . and modules/deployments; defaults.run.working-directory uses matrix.path. Set fail-fast=false so both suites produce evidence. No continue-on-error. Preserve job ID and event triggers; use contents:read and remove unused AWS credentials. Pin Terraform1.17.1 (already used successfully for these mocks), checkoutv7.0.1 and setup-terraformv4.0.1 verified from official action metadata. No module interface/provider/runtime changes or upstream module sourcing.

## Standards and evidence

Shared guidance comes from terraform-module-developer and receiving-code-review skills. Project constitution is placeholder. Source/interface unchanged; this package supplies requested module-automation evidence before editing, without exemption. No standards conflicts, required-input drift or live infrastructure work. Native test discovery and exit-code propagation directly address the review finding.

## Verification

Run actionlint and parse workflow for both matrix paths, Terraform version, run working directories and absence of failure suppression. Initialize/validate/test locally in both exact matrix directories using pinned Terraform. If demonstrating failure propagation, use an isolated temporary intentionally failing test, never modify real tests or apply infrastructure. Record local versus hosted evidence separately. No commit/push/hosted run.

## Verification results

- actionlint1.7.12 passed the changed workflow; YAML inspection confirmed matrixpaths . and modules/deployments, matching run working directories and no step/job failure suppression.
- Same pinned Terraform1.17.1 and exact init/validate/test sequence passed locally at root (54passed,0failed) and modules/deployments (2passed,0failed). Logs:/private/tmp/terraform-ci-matrix-mcuuumwm.
- Isolated temporary deployment copy intentionally changed one expected deployment count from2to999; native terraform test failed its assertion and returnedexit1. Original source/tests unchanged. Logs:/private/tmp/deployment-ci-negative-ce4d8rl9/negative-test.log.
- git diff-check passed. Independent workflow review found no material findings.
- These are local checks, not evidence of a hosted GitHub Actions run. No commit/push/workflow trigger, infrastructure apply or consumer YAML change was performed.
