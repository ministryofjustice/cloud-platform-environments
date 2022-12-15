module "content_hub_elasticsearch" {
  source                 = "github.com/ministryofjustice/cloud-platform-terraform-elasticsearch?ref=4.0.3"
  vpc_name               = var.vpc_name
  eks_cluster_name       = var.eks_cluster_name
  application            = var.application
  business-unit          = var.business-unit
  environment-name       = var.environment-name
  infrastructure-support = var.infrastructure-support
  is-production          = var.is-production
  team_name              = var.team_name
  elasticsearch-domain   = "hub-search"
  namespace              = var.namespace
  elasticsearch_version  = "7.1"
  instance_type          = "t2.small.elasticsearch"
  ebs_iops               = 0
  ebs_volume_type        = "gp2"
}

