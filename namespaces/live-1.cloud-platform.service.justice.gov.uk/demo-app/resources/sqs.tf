module "test_sqs_one" {
  source = "github.com/ministryofjustice/cloud-platform-terraform-sqs?ref=iam-policies"

  environment-name       = "test"
  team_name              = "cloud-platform"
  infrastructure-support = "platforms@digital.justice.gov.uk"
  application            = "demoapp"

  providers = {
    aws = "aws.london"
  }
}

module "test_sqs_two" {
  source = "github.com/ministryofjustice/cloud-platform-terraform-sqs?ref=iam-policies"

  environment-name       = "test"
  team_name              = "cloud-platform"
  infrastructure-support = "platforms@digital.justice.gov.uk"
  application            = "demoapp"

  providers = {
    aws = "aws.london"
  }
}

resource "kubernetes_secret" "test_sqs" {
  metadata {
    name      = "test_sqs"
    namespace = "demo-app"
  }

  data {
    access_key_id     = "${module.test_sqs_one.access_key_id}"
    secret_access_key = "${module.test_sqs_one.secret_access_key}"
    sqs_one_id        = "${module.test_sqs_one.sqs_id}"
    sqs_one_arn       = "${module.test_sqs_one.sqs_arn}"
    sqs_two_id        = "${module.test_sqs_two.sqs_id}"
    sqs_two_arn       = "${module.test_sqs_two.sqs_arn}"
  }
}
