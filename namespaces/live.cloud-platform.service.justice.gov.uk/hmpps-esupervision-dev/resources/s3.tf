module "s3_data_bucket" {
  source = "github.com/ministryofjustice/cloud-platform-terraform-s3-bucket?ref=5.2.0"

  team_name              = var.team_name
  business_unit          = var.business_unit
  application            = var.application
  is_production          = var.is_production
  environment_name       = var.environment
  infrastructure_support = var.infrastructure_support
  namespace              = var.namespace


  /*
   * NOTE: CORS config might be required in future
   * The following example can be used if you need to define CORS rules for your s3 bucket.
   *  Follow the guidance here "https://www.terraform.io/docs/providers/aws/r/s3_bucket.html#using-cors"
   *

  cors_rule =[
    {
      allowed_headers = ["*"]
      allowed_methods = ["GET"]
      allowed_origins = ["https://s3-website-test.hashicorp.com"]
      expose_headers  = ["ETag"]
      max_age_seconds = 3000
    },
    {
      allowed_headers = ["*"]
      allowed_methods = ["PUT"]
      allowed_origins = ["https://s3-website-test.hashicorp.com"]
      expose_headers  = [""]
      max_age_seconds = 3000
    },
  ]

  */
}

# info about the bucket
resource "kubernetes_secret" "s3_bucket" {
  metadata {
    name      = "hmpps-esupervision-data-s3-bucket"
    namespace = var.namespace
  }

  data = {
    bucket_arn  = module.s3_data_bucket.bucket_arn
    bucket_name = module.s3_data_bucket.bucket_name
  }
}
