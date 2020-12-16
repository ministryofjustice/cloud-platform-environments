/*
 Based on https://github.com/ministryofjustice/cloud-platform-terraform-s3-bucket/tree/master/example
 */
module "track_a_move_s3_bucket" {
  source = "github.com/ministryofjustice/cloud-platform-terraform-s3-bucket?ref=4.5"

  team_name              = var.team_name
  business-unit          = "Digital and Technology"
  application            = var.application
  infrastructure-support = var.infrastructure_support

  is-production    = var.is_production
  environment-name = var.environment
  namespace        = var.namespace

  providers = {
    # Can be either "aws.london" or "aws.ireland"
    aws = aws.london
  }

  versioning = false
}

resource "kubernetes_secret" "track_a_move_s3_bucket" {
  metadata {
    name      = "track-a-move-s3-bucket"
    namespace = var.namespace
  }

  data = {
    access_key_id     = module.track_a_move_s3_bucket.access_key_id
    secret_access_key = module.track_a_move_s3_bucket.secret_access_key
    bucket_arn        = module.track_a_move_s3_bucket.bucket_arn
    bucket_name       = module.track_a_move_s3_bucket.bucket_name
  }
}
