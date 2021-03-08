################################################################################
# Cloud Platform
# CP Test Elasticsearch cluster
#################################################################################

module "test_es_1" {
  source                    = "github.com/ministryofjustice/cloud-platform-terraform-elasticsearch?ref=fix-resource-expression"
  cluster_name              = var.cluster_name
  cluster_state_bucket      = var.cluster_state_bucket
  application               = "cloud-platform-esupg"
  business-unit             = "Platforms"
  environment-name          = "dev"
  infrastructure-support    = "platforms@digital.justice.gov.uk"
  is-production             = "false"
  team_name                 = "webops"
  elasticsearch-domain      = "es-1"
  namespace                 = var.namespace
  elasticsearch_version     = "6.8"
  aws_es_proxy_service_name = "aws-es-proxy-es-1"
}


module "ns_annotation" {
  source              = "github.com/ministryofjustice/cloud-platform-terraform-ns-annotation?ref=0.0.2"
  ns_annotation_roles = [module.test_es_1.aws_iam_role_name]
  namespace           = var.namespace
}

