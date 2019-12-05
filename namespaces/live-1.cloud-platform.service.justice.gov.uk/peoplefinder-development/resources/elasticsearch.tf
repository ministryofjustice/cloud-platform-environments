/*
 * Make sure that you use the latest version of the module by changing the
 * `ref=` value in the `source` attribute to the latest version listed on the
 * releases page of this repository.
 *
 */
module "peoplefinder_es" {
  source                 = "github.com/ministryofjustice/cloud-platform-terraform-elasticsearch?ref=3.0"
  cluster_name           = var.cluster_name
  cluster_state_bucket   = var.cluster_state_bucket
  application            = "peoplefinder"
  business-unit          = "Central Digital"
  environment-name       = "development"
  infrastructure-support = "people-finder-support@digital.justice.gov.uk"
  is-production          = "false"
  team_name              = "peoplefinder"
  elasticsearch-domain   = "peoplefinder-development-es"
  namespace              = "peoplefinder-development"
  elasticsearch_version  = "1.5"
}
