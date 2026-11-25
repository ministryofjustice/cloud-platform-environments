resource "kubernetes_secret" "large-court-cases-s3-bucket-secret" {
  ## For metadata use - not _
  metadata {
    name = "large-court-cases-s3-bucket"
    namespace = var.namespace
  }

  data = {
    bucket_name = data.aws_ssm_parameter.large-court-cases-s3-bucket-name.value
  }

}