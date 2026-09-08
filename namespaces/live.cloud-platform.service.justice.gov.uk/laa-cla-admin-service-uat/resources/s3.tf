module "static_files_bucket" {
  source                        = "github.com/ministryofjustice/cloud-platform-terraform-s3-bucket?ref=5.3.1"
  acl                           = "private"
  enable_allow_block_pub_access = true
  team_name                     = var.team_name
  business_unit                 = var.business_unit
  application                   = var.application
  is_production                 = var.is_production
  environment_name              = var.environment-name
  infrastructure_support        = var.infrastructure_support
  namespace                     = var.namespace

  providers = {
    aws = aws.london
  }
}

resource "kubernetes_secret" "k8_secrets" {
  metadata {
    name      = "s3"
    namespace = var.namespace
  }

  data = {
    static_files_bucket_name    = module.static_files_bucket.bucket_name
    static_files_bucket_arn     = module.static_files_bucket.bucket_arn
  }
}