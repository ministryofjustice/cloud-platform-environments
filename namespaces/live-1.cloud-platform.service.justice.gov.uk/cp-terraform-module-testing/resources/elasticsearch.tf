/*
 * When using this module through the cloud-platform-environments, the following
 * two variables are automatically supplied by the pipeline.
 *
 */

/*
 * Make sure that you use the latest version of the module by changing the
 * `ref=` value in the `source` attribute to the latest version listed on the
 * releases page of this repository.
 *
 */
module "example_team_es" {
  source                 = "github.com/ministryofjustice/cloud-platform-terraform-elasticsearch?ref=3.0"
  cluster_name           = var.cluster_name
  cluster_state_bucket   = var.cluster_state_bucket
  application            = "cptf11app"
  business-unit          = "example-bu"
  environment-name       = "dev"
  infrastructure-support = "cloud-platform@digital.justice.gov.uk"
  is-production          = "false"
  team_name              = "cp-team"
  elasticsearch-domain   = "tf-es"
  namespace              = "cp-terraform-module-testing"

  # change the elasticsearch version as you see fit.
  elasticsearch_version = "7.1"
}

