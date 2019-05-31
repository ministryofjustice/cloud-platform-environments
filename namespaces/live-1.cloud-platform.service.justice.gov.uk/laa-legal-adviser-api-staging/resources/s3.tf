module "s3" {
  source = "github.com/ministryofjustice/cloud-platform-terraform-s3-bucket?ref=3.2"

  team_name              = "${var.team_name}"
  business-unit          = "${var.business-unit}"
  application            = "${var.application}"
  is-production          = "${var.is-production}"
  environment-name       = "${var.environment-name}"
  infrastructure-support = "${var.email}"

  providers = {
    aws = "aws.london"
  }
}

resource "kubernetes_secret" "s3" {
  metadata {
    name      = "s3"
    namespace = "${var.namespace}"
  }

  data {
    access_key_id     = "${module.s3.access_key_id}"
    secret_access_key = "${module.s3.secret_access_key}"
    bucket_arn        = "${module.s3.bucket_arn}"
    bucket_name       = "${module.s3.bucket_name}"
    region            = "eu-west-2"
  }
}
