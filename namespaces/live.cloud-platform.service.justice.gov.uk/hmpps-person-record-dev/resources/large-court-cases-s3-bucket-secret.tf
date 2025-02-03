resource "kubernetes_secret" "large-court-cases-s3-bucket-secret" {
  ## For metadata use - not _
  metadata {
    name = "large-court-cases-s3-bucket"
    namespace = var.namespace
  }

  data = {
    bucket_name = data.large-court-cases-s3-credentials.bucket_name
  }

}