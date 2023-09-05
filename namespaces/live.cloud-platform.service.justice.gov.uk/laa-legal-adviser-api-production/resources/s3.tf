module "s3" {
  source = "github.com/ministryofjustice/cloud-platform-terraform-s3-bucket?ref=4.9.0"

  team_name              = var.team_name
  business_unit          = var.business_unit
  application            = var.application
  is_production          = var.is_production
  environment_name       = var.environment-name
  infrastructure_support = var.email
  namespace              = var.namespace

  providers = {
    aws = aws.london
  }
}

resource "kubernetes_secret" "s3" {
  metadata {
    name      = "s3"
    namespace = var.namespace
  }

  data = {
    access_key_id     = module.s3.access_key_id
    secret_access_key = module.s3.secret_access_key
    bucket_arn        = module.s3.bucket_arn
    bucket_name       = module.s3.bucket_name
    region            = "eu-west-2"
  }
}
