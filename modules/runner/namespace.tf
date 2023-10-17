resource "kubernetes_namespace_v1" "runner" {
  count = var.create_namespace ? 1 : 0

  metadata {
    name = var.namespace
  }
}
