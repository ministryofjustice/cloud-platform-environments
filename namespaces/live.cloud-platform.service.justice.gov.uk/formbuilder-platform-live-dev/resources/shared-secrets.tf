resource "kubernetes_secret" "formbuilder_platform_test_dev" {
  metadata {
    name      = "policy-arns"
    namespace = "formbuilder-saas-live"
  }

  data = {
    service_metadata_bucket_irsa = module.service-metadata-s3-bucket.irsa_policy_arn
  }
}
