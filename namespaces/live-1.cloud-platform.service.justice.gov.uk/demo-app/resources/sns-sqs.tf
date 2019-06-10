module "test_sns" {
  source = "github.com/ministryofjustice/cloud-platform-terraform-sns-topic?ref=3.0"

  team_name          = "cloud-platform"
  topic_display_name = "demo-app-topic"
}

module "test_sqs" {
  source = "github.com/ministryofjustice/cloud-platform-terraform-sqs?ref=3.0"

  environment-name       = "another-test"
  team_name              = "cloud-platform"
  infrastructure-support = "platforms@digital.justice.gov.uk"
  application            = "demoapp"
  existing_user_name     = "${module.test_sns.user_name}"

  providers = {
    aws = "aws.london"
  }
}

resource "kubernetes_secret" "test_sns_sqs" {
  metadata {
    name      = "test-sns-sqs"
    namespace = "demo-app"
  }

  data {
    access_key_id     = "${module.test_sns.access_key_id}"
    secret_access_key = "${module.test_sns.secret_access_key}"
    topic_arn         = "${module.test_sns.topic_arn}"
    sqs_id            = "${module.test_sqs.sqs_id}"
    sqs_arn           = "${module.test_sqs.sqs_arn}"
  }
}
