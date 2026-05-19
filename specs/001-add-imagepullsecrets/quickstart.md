# Quickstart: Validate imagePullSecrets Support

## Configured Behavior

1. Configure either the root module or `modules/runner/tests/basic/1-example.tf` with:

   ```hcl
   image_pull_secrets = [
     {
       name = "regcred"
     }
   ]

   namespace_labels = {
     "app.kubernetes.io/name" = "bitbucket-runner"
   }
   ```

2. Run formatting and validation from the runner module or repository root:

   ```sh
   terraform fmt -recursive
   terraform -chdir=modules/runner init -backend=false
   terraform -chdir=modules/runner validate
   ```

3. Inspect the generated plan or provider configuration to confirm the runner CronJob pod spec includes an image pull secret named `regcred`.

## Default Behavior

1. Remove or omit `image_pull_secrets`.
2. Plan or validate the runner module.
3. Confirm no image pull secret entries are rendered.
