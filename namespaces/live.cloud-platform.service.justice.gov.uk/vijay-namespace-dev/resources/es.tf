module "test_elasticsearch" {
  source = "github.com/ministryofjustice/cloud-platform-terraform-elasticsearch?ref=es-eks-irsa"

  cluster_name           = var.cluster_name
  application            = var.application
  business-unit          = var.business-unit
  environment-name       = var.environment-name
  infrastructure-support = var.infrastructure-support
  is-production          = var.is_production
  team_name              = var.team_name
  elasticsearch-domain   = "vv-test"
  namespace              = var.namespace
  elasticsearch_version  = "7.10"
}
