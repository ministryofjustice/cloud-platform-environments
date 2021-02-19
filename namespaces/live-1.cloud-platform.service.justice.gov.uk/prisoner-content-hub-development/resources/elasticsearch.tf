module "content_hub_elasticsearch" {
  source                 = "github.com/ministryofjustice/cloud-platform-terraform-elasticsearch?ref=3.8.0"
  cluster_name           = var.cluster_name
  cluster_state_bucket   = var.cluster_state_bucket
  application            = var.application
  business-unit          = var.business-unit
  environment-name       = var.environment-name
  infrastructure-support = var.infrastructure-support
  is-production          = var.is-production
  team_name              = var.team_name
  elasticsearch-domain   = "hub-search"
  namespace              = var.namespace
  elasticsearch_version  = "7.1"
}

module "ns_annotation" {
  source              = "github.com/ministryofjustice/cloud-platform-terraform-ns-annotation?ref=0.0.2"
  ns_annotation_roles = [module.content_hub_elasticsearch.aws_iam_role_name]
  namespace           = var.namespace
}