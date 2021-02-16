################################################################################
# Cloud Platform
# CP Test Elasticsearch cluster
#################################################################################

module "test_es_1" {
  source                 = "github.com/ministryofjustice/cloud-platform-terraform-elasticsearch?ref=remove-ns-annotation"
  cluster_name           = var.cluster_name
  cluster_state_bucket   = var.cluster_state_bucket
  application            = "cloud-platform-esupg"
  business-unit          = "Platforms"
  environment-name       = "dev"
  infrastructure-support = "platforms@digital.justice.gov.uk"
  is-production          = "false"
  team_name              = "webops"
  elasticsearch-domain   = "es-1"
  namespace              = var.namespace
  elasticsearch_version  = "6.8"
}

module "test_es_2" {
  source                 = "github.com/ministryofjustice/cloud-platform-terraform-elasticsearch?ref=remove-ns-annotation"
  cluster_name           = var.cluster_name
  cluster_state_bucket   = var.cluster_state_bucket
  application            = "cloud-platform-esupg"
  business-unit          = "Platforms"
  environment-name       = "dev"
  infrastructure-support = "platforms@digital.justice.gov.uk"
  is-production          = "false"
  team_name              = "webops"
  elasticsearch-domain   = "es-2"
  namespace              = var.namespace
  elasticsearch_version  = "6.8"
}


# dependency with es module. pass the role name from the es module


module "ns_annotation" {
  source                 = "https://github.com/ministryofjustice/cloud-platform-terraform-ns-annotation?ref=main"
  ns_annotation_roles = [module.test_es_1.aws_iam_role_name, module.test_es_2.aws_iam_role_name]
  namespace = var.namespace
}


