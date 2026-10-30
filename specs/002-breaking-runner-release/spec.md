# Declare the runner upgrade as breaking

The DMVP-10274 change upgrades providers and default container images. Preserve
the requested upgrades and document consumer migration and the required final
squash commit using standard semantic-release behavior.

Acceptance: migration notes list old/new requirements and rollout constraints;
an exact squash message uses `feat(DMVP-10274)` and includes `BREAKING CHANGE:`;
verify that fix alone is patch, feat alone is minor, and feat plus footer is major.
Per requester direction, do not add a custom release gate or modify release automation.
No publication,
history rewrite, infrastructure apply, or consumer YAML changes are authorized.
