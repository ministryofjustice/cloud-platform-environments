resource "kubernetes_secret" "cpr-large-court-cases-s3-bucket-secret" {
  ## For metadata use - not _
  metadata {
    name = "cpr-large-court-cases-s3-bucket"
    namespace = var.namespace
  }

  data = {
    bucket_name = data.aws_ssm_parameter.cpr-large-court-cases-s3-bucket-name.value
  }
}