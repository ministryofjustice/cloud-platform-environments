resource "kubernetes_secret" "analytical_platform_s3_bucket" {
  metadata {
    name      = "analytical-platform-s3-bucket-output"
    namespace = var.namespace
  }

  data = {
    access_key_id     = ""
    secret_access_key = ""
    bucket_arn        = "arn:aws:s3:::alpha-manage-my-prison"
    bucket_name       = "alpha-manage-my-prison"
  }
}
