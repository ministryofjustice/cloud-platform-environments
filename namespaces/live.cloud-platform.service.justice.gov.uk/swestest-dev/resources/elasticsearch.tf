/*
 * Make sure that you use the latest version of the module by changing the
 * `ref=` value in the `source` attribute to the latest version listed on the
 * releases page of this repository.
 *
 */
module "sw_test_es" {
  source                 = "github.com/ministryofjustice/cloud-platform-terraform-elasticsearch?ref=3.9.6"
  cluster_name           = var.cluster_name
  team_name              = var.team_name
  business-unit          = var.business_unit
  application            = var.application
  is-production          = var.is_production
  environment-name       = var.environment
  infrastructure-support = var.infrastructure_support
  namespace              = var.namespace

  elasticsearch-domain = "test-es"

  # change the elasticsearch version as you see fit.
  elasticsearch_version = "7.10"

  # This will enable creation of manual snapshot in s3 repo, provide the "s3 bucket arn" to create snapshot in s3.
  # s3_manual_snapshot_repository = "s3-bucket-arn"

}