/*
 * Make sure that you use the latest version of the module by changing the
 * `ref=` value in the `source` attribute to the latest version listed on the
 * releases page of this repository.
 *
 */
module "cccd_staging_claims_submitted_sns" {
  source = "github.com/ministryofjustice/cloud-platform-terraform-sns-topic?ref=2.0"

  team_name          = "laa-get-paid"
  topic_display_name = "cccd-staging-claims-submitted-sns"
  aws_region         = "eu-west-2"
}

resource "kubernetes_secret" "cccd_staging_claims_submitted_sns" {
  metadata {
    name      = "cccd-staging-claims-submitted-sns-output"
    namespace = "cccd-staging"
  }

  data {
    access_key_id     = "${module.cccd_staging_claims_submitted_sns.access_key_id}"
    secret_access_key = "${module.cccd_staging_claims_submitted_sns.secret_access_key}"
    topic_arn         = "${module.cccd_staging_claims_submitted_sns.topic_arn}"
  }
}
