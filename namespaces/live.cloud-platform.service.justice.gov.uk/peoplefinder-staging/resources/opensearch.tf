module "peoplefinder_opensearch" {
  source = "github.com/ministryofjustice/cloud-platform-terraform-opensearch?ref=1.5.0"

  application            = var.application
  business_unit          = var.business_unit
  environment_name       = var.environment
  infrastructure_support = var.infrastructure_support
  is_production          = var.is_production
  team_name              = var.team_name
  namespace              = var.namespace

  vpc_name         = var.vpc_name
  eks_cluster_name = var.eks_cluster_name

  engine_version      = "OpenSearch_2.7"
  snapshot_bucket_arn = module.peoplefinder_s3.bucket_arn

  cluster_config = {
    instance_count = 2
    instance_type  = "t3.small.search"
  }

  ebs_options = {
    volume_size = 10 # Storage (GBs) per node
  }
}

resource "kubernetes_secret" "peoplefinder_opensearch" {
  metadata {
    name      = "peoplefinder-opensearch-output"
    namespace = var.namespace
  }

  data = {
    proxy_url = module.peoplefinder_opensearch.proxy_url
  }
}
