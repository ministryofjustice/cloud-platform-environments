resource "kubernetes_secret" "s3" {
  metadata {
    name      = "s3-output"
    namespace = var.namespace
  }

  data = {
    bucket_arn  = "placeholder value"
    bucket_name = "placeholder value"
  }
}
