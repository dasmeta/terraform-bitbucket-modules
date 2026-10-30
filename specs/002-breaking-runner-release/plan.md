# Breaking release plan

## Scope and current design

The requester chose standard semantic-release commit classification and explicitly
removed the custom release gate. Restore package.json and the semantic-release
workflow to HEAD, remove .github/semantic-release, and keep migration notes.
The pending CI matrix correction and restored historical feature records remain.
No module interface or runtime changes are part of this correction.

The final squash message uses feat(DMVP-10274) plus an explicit BREAKING CHANGE:
footer. A feat subject alone is minor, which is insufficient to declare this
provider/runtime upgrade as breaking. Keep the PR title in the existing required
DMVP-10274 format and edit the final squash commit message when merging.
There is no automated footer enforcement; the final commit must retain it.

## Validation

Verify fix -> patch, feat -> minor, and the documented feat + footer -> major
with semantic-release 19's analyzer 9.0.2 from the isolated temporary installation.
Confirm removed plugin references and exact restoration of the two release files.
Run actionlint on the still-changed Terraform CI workflow and git diff --check.
Previously run custom-gate tests do not describe the final implementation.
No commit, push, release, GitHub settings write, or infrastructure apply.

## Results

Analyzer 9.0.2 verified all three cases: fix -> patch, feat -> minor, and the
documented feat with footer -> major. The custom directory is absent, both
release files match HEAD, the Terraform CI workflow passes actionlint, and
git diff --check passes. Other review corrections remain in the working tree.
