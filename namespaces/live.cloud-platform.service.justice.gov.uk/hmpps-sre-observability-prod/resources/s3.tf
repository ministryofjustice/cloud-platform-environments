module "dependencytrack_backup_s3_bucket" {
  source = "github.com/ministryofjustice/cloud-platform-terraform-s3-bucket?ref=5.3.1"

  providers = {
    aws = aws.london
  }

  team_name                     = var.team_name
  business_unit                 = var.business_unit
  application                   = var.application
  is_production                 = var.is_production
  environment_name              = var.environment
  infrastructure_support        = var.infrastructure_support
  namespace                     = var.namespace
  versioning                    = true
  enable_allow_block_pub_access = true

  bucket_policy = <<EOF
  {
    "Version": "2012-10-17",
    "Statement": []
  }
  EOF

}

resource "kubernetes_secret" "dependencytrack_backup_s3_bucket" {
  metadata {
    name      = "s3-bucket-output"
    namespace = var.namespace
  }

  data = {
    bucket_arn           = module.dependencytrack_backup_s3_bucket.bucket_arn
    bucket_name          = module.dependencytrack_backup_s3_bucket.bucket_name
    role_arn             = module.irsa.role_arn
    service_account_name = module.irsa.service_account_name
  }
}
