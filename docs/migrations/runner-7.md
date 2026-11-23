# Runner 6.1.3 to 7.1.3 migration (DMVP-11012)

## Release impact

This default-runtime change requires a **major module release** after v2.0.0,
including for consumers of `modules/runner`. Omitting `runner_image` or setting it
to `null` now selects Runner 7.1.3 instead of 6.1.3. Explicit image overrides
continue to take precedence. Terraform inputs, provider requirements, resource
addresses, and the `docker:29.9.2-dind` default are unchanged by this update.

Runner 7.1.0 changed its WebSocket endpoint to
`wss://bitbucket-pipelines-websocket.atlassian.com/ws`. Existing installations
with restrictive egress or proxy rules may need migration before using 7.1.3.
See the [upstream changelog](https://runners.bitbucket.org/downloads/CHANGELOG.md)
and [Atlassian firewall guidance](https://support.atlassian.com/bitbucket-cloud/docs/ip-addresses-for-runners-behind-corporate-firewalls/).

## Migration and rollback

1. Record the current module version, runner image reference, and resolved image
   digest. Keep the current module version pinned until ready for the runtime change.
2. Before upgrading, allow outbound TLS/WebSocket connections on port 443 to
   `bitbucket-pipelines-websocket.atlassian.com`, including proxy WebSocket upgrades
   where applicable. Retain the other endpoints required by Atlassian's guidance.
3. Upgrade to the new major module version and review `terraform plan`. Remove an
   older explicit `runner_image` override or update it to 7.1.3 to receive the fix.
   Callers that must retain their prior runtime must explicitly pin its known
   reference/digest; changing the module version alone will change the default.
4. Apply in a non-production environment first. Drain active pipeline work before
   retiring the existing Runner Job. CronJob template changes apply only to new
   Jobs; `Forbid` prevents a scheduled replacement while the old Job is active.
   Manually created Jobs do not share this concurrency protection.
5. Confirm the replacement Runner is ONLINE and run a representative pipeline
   covering checkout, Docker build/run/push, registry authentication, caches, and
   artifacts. Native Terraform mock tests do not establish live compatibility.
   Proceed to production after these checks pass.

For rollback, restore the recorded image reference/digest through `runner_image`,
review/apply the plan, and drain and replace the current Job in the same manner.
Rolling back to an affected Java runtime also restores the CVE risk unless the
actual Runner JVM retains a supported temporary mitigation, such as
`-XX:-UseBASE64Intrinsics`. Do not treat an older image override as a security fix.
See the [Temurin advisory](https://adoptium.net/news/2026/11/temurin-november-2026-cspu-java4shell/).

## Reproducible Java image inspection

On 2026-11-23, the following immutable Runner 7.1.3 image was inspected for
**Linux amd64**. This evidence establishes the Java build in that specific image;
the upstream changelog independently documents the `-XX:UseAVX=2` mitigation.
It does not establish pipeline compatibility or the contents of a future
republished mutable tag.

```sh
docker run --rm --platform linux/amd64 --network none --read-only --cap-drop ALL \
  --entrypoint java \
  docker-public.packages.atlassian.com/sox/atlassian/bitbucket-pipelines-runner@sha256:6837488d67470a0a65017473d1da86d8df934c2398079f9beca085a1f34a50ad \
  -version
```

Observed output:

```text
openjdk version "25.0.5.1" 2026-11-17 LTS
OpenJDK Runtime Environment Temurin-25.0.5.1+2 (build 25.0.5.1+2-LTS)
OpenJDK 64-Bit Server VM Temurin-25.0.5.1+2 (build 25.0.5.1+2-LTS, mixed mode, sharing)
```

The [Temurin advisory](https://adoptium.net/news/2026/11/temurin-november-2026-cspu-java4shell/)
identifies 25.0.5.1+2 as containing the CVE-2026-114938 fix. Recheck the resolved
image digest and runtime when deploying another image or architecture.

## Release and squash instructions

The existing `fix(DMVP-11012)` commit alone produces a patch release. A `feat`
subject alone produces a minor release. Use an explicit `BREAKING CHANGE:` footer
for this major release; changing only the PR title or adding `!` alone does not
satisfy the repository's configured semantic-release 19 Angular preset.

Keep the PR title compatible with the required `DMVP-11012: ...` format. When
squashing, use the following **final commit title and body**, retaining the footer:

```text
fix(DMVP-11012): upgrade default runner to 7.1.3

Address CVE-2026-114938 and document the runner network migration.
See docs/migrations/runner-7.md for rollout, rollback, and image evidence.

BREAKING CHANGE: The default runner image changes from 6.1.3 to 7.1.3. Restricted-egress installations must allow wss://bitbucket-pipelines-websocket.atlassian.com/ws before upgrading; pin runner_image explicitly to retain the prior runtime.
```

If merging without squash, include a commit with this breaking footer in the
branch before merging. A documentation-only follow-up commit without the footer
will not correct release classification. No custom release rules are required.
