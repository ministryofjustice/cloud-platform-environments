# S3 Bucket
module "ap_gh_collab_repo_s3_bucket" {
  source = "github.com/ministryofjustice/cloud-platform-terraform-s3-bucket?ref=5.1.0"
  acl    = "private"

  team_name              = var.team_name
  business_unit          = var.business_unit
  application            = var.application
  is_production          = var.is_production
  environment_name       = var.environment
  infrastructure_support = var.infrastructure_support
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
    bucket_arn = module.ap_gh_collab_repo_s3_bucket.bucket_arn
  }
}

# State Lock
module "ap_gh_collab_repo_tf_state_lock" {
  source = "github.com/ministryofjustice/cloud-platform-terraform-dynamodb-cluster?ref=4.0.0"

  team_name              = var.team_name
  application            = var.application
  business_unit          = var.business_unit
  environment_name       = var.environment
  infrastructure_support = var.infrastructure_support
  is_production          = var.is_production
  namespace              = var.namespace

  hash_key          = "LockID"
  enable_encryption = "true"
  enable_autoscaler = "true"
}

resource "kubernetes_secret" "ap_gh_collab_repo_tf_state_lock" {
  metadata {
    name      = "ap-gh-collab-repo-tf-state-lock-table"
    namespace = var.namespace
  }

  data = {
    table_name = module.ap_gh_collab_repo_tf_state_lock.table_name
    table_arn  = module.ap_gh_collab_repo_tf_state_lock.table_arn
  }
}
