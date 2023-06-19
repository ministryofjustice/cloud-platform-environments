module "ap_gh_collab_repo_s3_bucket" {
  source = "github.com/ministryofjustice/cloud-platform-terraform-s3-bucket?ref=4.8.2"
  acl    = "private"

  team_name              = var.team_name
  business-unit          = var.business_unit
  application            = var.application
  is-production          = var.is_production
  environment-name       = var.environment
  infrastructure-support = var.infrastructure_support
  namespace              = var.namespace

  providers = {
    aws = aws.london
  }
}

resource "kubernetes_secret" "ap_gh_collab_repo_s3_bucket" {
  metadata {
    name      = "tfstate-s3-bucket-ap-gh-collab-repo"
    namespace = var.namespace
  }

  data = {
    access_key_id     = module.ap_gh_collab_repo_s3_bucket.access_key_id
    secret_access_key = module.ap_gh_collab_repo_s3_bucket.secret_access_key
    bucket_arn        = module.ap_gh_collab_repo_s3_bucket.bucket_arn
  }
}
