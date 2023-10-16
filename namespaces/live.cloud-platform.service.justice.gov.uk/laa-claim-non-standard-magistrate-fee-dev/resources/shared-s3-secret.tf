resource "kubernetes_secret" "claim-nsm-s3-secret" {
  metadata {
    name      = "s3-policy-arns"
    namespace = "laa-assess-non-standard-magistrate-fee-dev"
  }

  data = {
    service_metadata_bucket_irsa = module.s3_bucket.irsa_policy_arn
  }
}