# auto-generated from fb-cloud-platforms-environments
##################################################
# User Filestore S3
module "user-filestore-s3-bucket" {
  source = "github.com/ministryofjustice/cloud-platform-terraform-s3-bucket?ref=3.0"

  team_name              = "${var.team_name}"
  acl                    = "private"
  versioning             = false
  business-unit          = "transformed-department"
  application            = "formbuilderuserfilestore"
  is-production          = "${var.is-production}"
  environment-name       = "${var.environment-name}"
  infrastructure-support = "${var.infrastructure-support}"
}

resource "kubernetes_secret" "user-filestore-s3-bucket" {
  metadata {
    name      = "s3-formbuilder-user-filestore-${var.environment-name}"
    namespace = "formbuilder-platform-${var.environment-name}"
  }

  data {
    access_key_id     = "${module.user-filestore-s3-bucket.access_key_id}"
    bucket_arn        = "${module.user-filestore-s3-bucket.bucket_arn}"
    bucket_name       = "${module.user-filestore-s3-bucket.bucket_name}"
    secret_access_key = "${module.user-filestore-s3-bucket.secret_access_key}"
  }
}
