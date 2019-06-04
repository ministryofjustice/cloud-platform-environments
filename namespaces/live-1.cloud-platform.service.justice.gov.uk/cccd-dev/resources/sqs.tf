module "responses_for_cccd" {
  source = "github.com/ministryofjustice/cloud-platform-terraform-sqs?ref=2.0"

  environment-name       = "dev"
  team_name              = "laa-get-paid"
  infrastructure-support = "crowncourtdefence@digtal.justice.gov.uk"
  application            = "cccd"

  providers = {
    aws = "aws.london"
  }
}

resource "kubernetes_secret" "responses_for_cccd" {
  metadata {
    name      = "responses-for-cccd-sqs"
    namespace = "cccd-dev"
  }

  data {
    access_key_id     = "${module.responses_for_cccd.access_key_id}"
    secret_access_key = "${module.responses_for_cccd.secret_access_key}"
    sqs_id            = "${module.responses_for_cccd.sqs_id}"
    sqs_arn           = "${module.responses_for_cccd.sqs_arn}"
  }
}

module "claims_for_ccr" {
  source = "github.com/ministryofjustice/cloud-platform-terraform-sqs?ref=2.0"

  environment-name       = "dev"
  team_name              = "laa-get-paid"
  infrastructure-support = "crowncourtdefence@digtal.justice.gov.uk"
  application            = "cccd"

  providers = {
    aws = "aws.london"
  }
}

resource "kubernetes_secret" "claims_for_ccr" {
  metadata {
    name      = "claims-for-ccr-sqs"
    namespace = "cccd-dev"
  }

  data {
    access_key_id     = "${module.claims_for_ccr.access_key_id}"
    secret_access_key = "${module.claims_for_ccr.secret_access_key}"
    sqs_id            = "${module.claims_for_ccr.sqs_id}"
    sqs_arn           = "${module.claims_for_ccr.sqs_arn}"
  }
}

module "claims_for_cclf" {
  source = "github.com/ministryofjustice/cloud-platform-terraform-sqs?ref=2.0"

  environment-name       = "dev"
  team_name              = "laa-get-paid"
  infrastructure-support = "crowncourtdefence@digtal.justice.gov.uk"
  application            = "cccd"

  providers = {
    aws = "aws.london"
  }
}

resource "kubernetes_secret" "claims_for_cclf" {
  metadata {
    name      = "claims-for-cclf-sqs"
    namespace = "cccd-dev"
  }

  data {
    access_key_id     = "${module.claims_for_cclf.access_key_id}"
    secret_access_key = "${module.claims_for_cclf.secret_access_key}"
    sqs_id            = "${module.claims_for_cclf.sqs_id}"
    sqs_arn           = "${module.claims_for_cclf.sqs_arn}"
  }
}

module "responses_for_cccd_dead_letter" {
  source = "github.com/ministryofjustice/cloud-platform-terraform-sqs?ref=2.0"

  environment-name       = "dev"
  team_name              = "laa-get-paid"
  infrastructure-support = "crowncourtdefence@digtal.justice.gov.uk"
  application            = "cccd"

  providers = {
    aws = "aws.london"
  }
}

resource "kubernetes_secret" "responses_for_cccd_dead_letter" {
  metadata {
    name      = "responses-for-cccd-dead-letter-sqs"
    namespace = "cccd-dev"
  }

  data {
    access_key_id     = "${module.responses_for_cccd_dead_letter.access_key_id}"
    secret_access_key = "${module.responses_for_cccd_dead_letter.secret_access_key}"
    sqs_id            = "${module.responses_for_cccd_dead_letter.sqs_id}"
    sqs_arn           = "${module.responses_for_cccd_dead_letter.sqs_arn}"
  }
}
