module "test_elasticsearch" {
  source = "github.com/ministryofjustice/cloud-platform-terraform-elasticsearch?ref=es-eks-irsa"

  cluster_name           = var.cluster_name
  application            = var.application
  business-unit          = var.business_unit
  environment-name       = var.environment
  infrastructure-support = var.infrastructure_support
  is-production          = var.is_production
  team_name              = var.team_name
  elasticsearch-domain   = "vv-test"
  namespace              = var.namespace
  instance_type          = "m5.large.elasticsearch"
}
