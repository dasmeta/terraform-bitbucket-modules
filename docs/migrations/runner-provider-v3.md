# Breaking runner upgrade (DMVP-10274)

This change requires a **major module release**, including when consuming only
`modules/runner`. Upgrading the module changes the provider and runtime even if
the caller does not set any of the new inputs. Keep the previous module version
until ready to migrate; an unconstrained module version does not protect consumers.

## Changed requirements and defaults

| Component | Previous release | New release |
| --- | --- | --- |
| Terraform (root and runner) | No explicit minimum | >= 1.3.0 |
| Runner Kubernetes provider | 2.23.0 | 3.4.0 (exact pin) |
| Runner image | `docker-public.packages.atlassian.com/sox/atlassian/bitbucket-pipelines-runner` (floating tag) | Same repository, tag `6.1.3` |
| Docker-in-Docker image | `docker:20.10.7-dind` | `docker:29.9.2-dind` |
| Deployments Bitbucket provider | 2.31.0 | 2.53.0 (exact pin) |

The deployments provider change affects consumers of `modules/deployments`;
the root wrapper uses the runner module. Requests/limits, scheduling constraints,
and pod annotations remain opt-in. The new inputs do not remove the upgrade impact
of the changed provider and image defaults.

## Consumer migration

1. Before upgrading, save the current module version, provider lock file and
   state backup using your normal backend procedure. Record the deployed runner
   and DinD image digests: the old untagged runner reference cannot reproduce a
   previous image reliably.
2. Use Terraform >= 1.3.0. Update any caller constraints that require Kubernetes
   2.x to allow the module's exact 3.4.0 pin. All modules in one configuration
   must agree on a provider version. For deployments consumers, reconcile the
   Bitbucket provider constraint with 2.53.0 as well.
3. Upgrade the module explicitly to the new major version, run
   `terraform init -upgrade`, and review both the lock-file diff and
   `terraform plan` before applying. Remove null entries from namespace label and
   annotation maps. Provider normalization can show empty metadata maps changing
   to null; assess the complete plan rather than assuming all changes are cosmetic.
4. Test a representative pipeline in staging: checkout, Docker build/run/push,
   registry authentication, caches and artifacts. Terraform mock tests verify
   configuration, not live provider migration or runner/DinD compatibility.
5. Drain active runner work before replacing Jobs. A CronJob template update
   applies to future Jobs; existing Pods keep their images. With `Forbid`, an
   active Job prevents the next scheduled Job. Manually created Jobs can overlap.

To retain a previously validated runtime while migrating the provider, set
`runner_image` and `dind_image` explicitly to your recorded references/digests.
These inputs do not change the provider requirement. Runtime rollback uses those
same inputs and a replacement Job after draining work. For a provider/module
rollback, follow the saved-version and backend-state recovery procedure; do not
assume Terraform state written by a newer provider can be read by an older one.

The `kubernetes_secret.runner` resource address remains unchanged. Do not rename
it to `kubernetes_secret_v1` as part of this upgrade: a resource-type/state
migration needs its own procedure.

## Release and squash instructions

The existing `fix(DMVP-10274)` commit has no breaking footer. Its subject alone
classifies as a patch under this repository's default semantic-release analyzer.
Changing `fix` to `feat` alone produces a minor release. Keep an explicit
`BREAKING CHANGE:` footer for a major release. Use this final squash message:

```text
feat(DMVP-10274): upgrade runner configuration and dependencies

Add configurable runner images, resources, security contexts and scheduling.
See docs/migrations/runner-provider-v3.md for migration and rollout instructions.

BREAKING CHANGE: Require Terraform >= 1.3.0, upgrade the runner Kubernetes provider from 2.23.0 to 3.4.0, change default runner/DinD images to 6.1.3/29.9.2-dind, and upgrade the deployments Bitbucket provider from 2.31.0 to 2.53.0. Update caller provider constraints, reinitialize and validate pipelines before rollout.
```

Keep the PR title in the repository's required `DMVP-10274: ...` format. Set the
**final squash commit** title and body to the message above during merge. GitHub
squash defaults can omit the description, so check that the final commit body
contains the footer. A `!` in the title alone is insufficient for the configured
semantic-release 19 analyzer. This change uses standard commit analysis, with no
custom release plugin or changes to repository settings.
