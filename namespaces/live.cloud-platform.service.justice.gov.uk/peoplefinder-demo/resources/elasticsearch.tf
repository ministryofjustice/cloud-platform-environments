################################################################################
# Peoplefinder
# Application Elasticsearch cluster
#################################################################################

module "peoplefinder_es" {
  source                 = "github.com/ministryofjustice/cloud-platform-terraform-elasticsearch?ref=4.0.2"
  vpc_name               = var.vpc_name
  eks_cluster_name       = var.eks_cluster_name
  application            = "peoplefinder"
  business-unit          = "Central Digital"
  environment-name       = "demo"
  infrastructure-support = "people-finder-support@digital.justice.gov.uk"
  is-production          = "false"
  team_name              = "peoplefinder"
  elasticsearch-domain   = "es"
  namespace              = "peoplefinder-demo"
  elasticsearch_version  = "7.9"
  instance_type          = "t2.small.elasticsearch"
  ebs_iops               = 0
  ebs_volume_type        = "gp2"

  advanced_options = {
    override_main_response_version = true
  }
}
