/*
 * Make sure that you use the latest version of the module by changing the
 * `ref=` value in the `source` attribute to the latest version listed on the
 * releases page of this repository.
 *
 */
module "track_a_query_credentials" {
  source    = "github.com/ministryofjustice/cloud-platform-terraform-ecr-credentials?ref=3.4"
  repo_name = "track-a-query"                                                                 # Arbitrary module name does not need to reference any existing modules
  team_name = "correspondence"                                                                # Github team name

  providers = {
    aws = "aws.london"
  }
}

resource "kubernetes_secret" "track_a_query_credentials" {
  metadata {
    name      = "track-a-query-credentials-output"
    namespace = "track-a-query-dev"
  }

  data {
    access_key_id     = "${module.track_a_query_credentials.access_key_id}"
    secret_access_key = "${module.track_a_query_credentials.secret_access_key}"
    repo_arn          = "${module.track_a_query_credentials.repo_arn}"
    repo_url          = "${module.track_a_query_credentials.repo_url}"
  }
}
