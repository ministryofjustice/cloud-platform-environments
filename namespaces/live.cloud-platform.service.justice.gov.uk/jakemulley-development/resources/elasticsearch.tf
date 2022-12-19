module "example" {
  source                 = "github.com/ministryofjustice/cloud-platform-terraform-elasticsearch?ref=add-enforce-https-option"
  vpc_name               = var.vpc_name
  eks_cluster_name       = var.eks_cluster_name
  team_name              = var.team_name
  business-unit          = var.business_unit
  application            = var.application
  is-production          = var.is_production
  environment-name       = var.environment
  infrastructure-support = var.infrastructure_support
  namespace              = var.namespace

  elasticsearch-domain      = "example"
  aws_es_irsa_sa_name       = "jm-test-es"
  aws_es_proxy_service_name = "jm-test-es"

  # change the elasticsearch version as you see fit.
  elasticsearch_version = "7.10"

  domain_endpoint_enforce_https = true
}

module "enforce" {
  source                    = "github.com/ministryofjustice/cloud-platform-terraform-elasticsearch?ref=add-enforce-https-option"
  vpc_name                  = var.vpc_name
  eks_cluster_name          = var.eks_cluster_name
  team_name                 = var.team_name
  business-unit             = var.business_unit
  application               = var.application
  is-production             = var.is_production
  environment-name          = var.environment
  infrastructure-support    = var.infrastructure_support
  namespace                 = var.namespace
  aws_es_irsa_sa_name       = "jm-test-es-enforce"
  aws_es_proxy_service_name = "jm-test-es-enforce"

  elasticsearch-domain = "enforce"

  # change the elasticsearch version as you see fit.
  elasticsearch_version = "7.10"

  domain_endpoint_enforce_https = false
}
