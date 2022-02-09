module "content_hub_elasticsearch" {
  source                 = "github.com/ministryofjustice/cloud-platform-terraform-elasticsearch?ref=3.9.2"
  cluster_name           = var.cluster_name
  application            = var.application
  business-unit          = var.business-unit
  environment-name       = var.environment-name
  infrastructure-support = var.infrastructure-support
  is-production          = var.is-production
  team_name              = var.team_name
  elasticsearch-domain   = "hub-search"
  namespace              = var.namespace
  elasticsearch_version  = "7.1"
  ebs_volume_size        = 50
  instance_type          = "t3.small.elasticsearch"
  irsa_enabled           = true
  assume_enabled         = false
}

module "ns_annotation" {
  source              = "github.com/ministryofjustice/cloud-platform-terraform-ns-annotation?ref=0.0.3"
  ns_annotation_roles = [module.content_hub_elasticsearch.aws_iam_role_name]
  namespace           = var.namespace
}
