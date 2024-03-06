resource "kubernetes_secret" "crime-forms-s3-secret" {
  metadata {
    name      = "s3-policy-arns"
    namespace = "laa-assess-crime-forms-prod"
  }

  data = {
    service_metadata_bucket_irsa = module.s3_bucket.irsa_policy_arn
    bucket_arn  = module.s3_bucket.bucket_arn
    bucket_name = module.s3_bucket.bucket_name
  }
}