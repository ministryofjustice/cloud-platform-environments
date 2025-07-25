module "hmpps_assessments_s3" {
  source                 = "github.com/ministryofjustice/cloud-platform-terraform-s3-bucket?ref=5.3.0"
  team_name              = var.team_name
  business_unit          = var.business_unit
  application            = var.application
  is_production          = var.is_production
  environment_name       = var.environment_name
  infrastructure_support = var.infrastructure_support
  namespace              = var.namespace

  providers = {
    aws = aws.london
  }

  /*
   * The following is used to set a lifecycle for documents in S3.
   *  Documentation here "https://www.terraform.io/docs/providers/aws/r/s3_bucket.html#using-object-lifecycle"
   *  "https://docs.aws.amazon.com/AmazonS3/latest/dev/object-lifecycle-mgmt.html"
   *
  */
  lifecycle_rule = [
    {
      enabled = true
      id      = "retire documents after 5 days"
      prefix  = "documents/"
      expiration = [
        {
          days = 5
        },
      ]
    },
  ]
}

resource "kubernetes_secret" "hmpps_assessments_s3_secret" {
  metadata {
    name      = "hmpps-assessments-s3"
    namespace = var.namespace
  }

  data = {
    bucket_arn  = module.hmpps_assessments_s3.bucket_arn
    bucket_name = module.hmpps_assessments_s3.bucket_name
  }
}
