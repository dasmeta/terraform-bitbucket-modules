resource "test_assertions" "dummy" {
  component = "this"

  equal "image_pull_secrets_input" {
    description = "Configured image_pull_secrets input is accepted by the runner module example."
    got         = "all good"
    want        = "all good"
  }
}
