module "live0_to_live1_migration_s3_bucket" {
  source                 = "github.com/ministryofjustice/cloud-platform-terraform-s3-bucket?ref=2.0"
  team_name              = "${var.team_name}"
  acl                    = "private"
  versioning             = false
  business-unit          = "${var.business_unit}"
  application            = "${var.application}"
  is-production          = "${var.is-production}"
  environment-name       = "${var.environment-name}"
  infrastructure-support = "${var.infrastructure-support}"
  aws-s3-region          = "${var.aws_region}"
}

resource "kubernetes_secret" "live0_to_live1_migration_s3_bucket" {
  metadata {
    name      = "sec-live0-to-live1-migration-s3-bucket"
    namespace = "${var.namespace}"
  }

  data {
    access_key_id     = "${module.live0_to_live1_migration_s3_bucket.access_key_id}"
    secret_access_key = "${module.live0_to_live1_migration_s3_bucket.secret_access_key}"
    bucket_arn        = "${module.live0_to_live1_migration_s3_bucket.bucket_arn}"
    bucket_name       = "${module.live0_to_live1_migration_s3_bucket.bucket_name}"
  }
}
