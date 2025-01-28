resource "kubernetes_secret" "crime-forms-s3-secret" {
  metadata {
    name      = "s3-policy-arns"
    namespace = "laa-assess-crime-forms-dev"
  }

  data = {
    service_metadata_bucket_irsa = module.s3_bucket.irsa_policy_arn
    bucket_arn  = module.s3_bucket.bucket_arn
    bucket_name = module.s3_bucket.bucket_name
  }
}

resource "kubernetes_secret" "crime-forms-s3-secret-for-app-store" {
  metadata {
    name      = "s3-policy-arns"
    namespace = "laa-crime-application-store-dev"
  }

  data = {
    service_metadata_bucket_irsa = module.s3_bucket.irsa_policy_arn
    bucket_arn  = module.s3_bucket.bucket_arn
    bucket_name = module.s3_bucket.bucket_name
  }
}
