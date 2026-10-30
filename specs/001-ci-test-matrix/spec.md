# CI test coverage specification

**Date**:2026-10-30
**Input**: Reviewer reports deployment tests are not run or enforced by CI; user explicitly requests fix.

## Requirements and acceptance

- CI invokes native terraform test separately at repository root and modules/deployments so both test directories are discovered.
- Either test failure fails its matrix job; no continue-on-error or shell failure suppression.
- Terraform supports mock providers (>=1.7); checks create no infrastructure and need no AWS credentials.
- Keep existing PR/main/master triggers. Do not change module source, tests, consumer YAML, releases or unrelated workflows.
- Local verification records actual commands/results; do not claim a hosted CI run before it happens.
