module "ccq_es" {
  source                 = "github.com/ministryofjustice/cloud-platform-terraform-elasticsearch?ref=4.0.4"
  cluster_name           = var.cluster_name
  team_name              = var.team_name
  business-unit          = var.business_unit
  application            = var.application
  is-production          = var.is_production
  environment-name       = var.environment
  infrastructure-support = var.infrastructure_support
  namespace              = var.namespace

  elasticsearch-domain = "ccq-es"

  # change the elasticsearch version as you see fit.
  elasticsearch_version = "7.10"

  # This will enable creation of manual snapshot in s3 repo, provide the "s3 bucket arn" to create snapshot in s3.
  s3_manual_snapshot_repository = "arn:aws:s3:::cloud-platform-3e6c3da39e4945b4b6ecb71bb8c9af6f"

}
