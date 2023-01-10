module "abundance_es" {
  source                 = "github.com/ministryofjustice/cloud-platform-terraform-elasticsearch?ref=4.0.4"
  eks_cluster_name       = var.eks_cluster_name
  vpc_name               = var.vpc_name
  team_name              = var.team_name
  business-unit          = var.business_unit
  application            = var.application
  is-production          = var.is_production
  environment-name       = var.environment
  infrastructure-support = var.infrastructure_support
  namespace              = var.namespace

  elasticsearch-domain = "ab-es"

  # change the elasticsearch version as you see fit.
  elasticsearch_version = "7.10"

}