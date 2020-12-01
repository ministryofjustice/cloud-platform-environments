module "probation_offender_search_es" {
  source                     = "github.com/ministryofjustice/cloud-platform-terraform-elasticsearch?ref=3.5.1"
  cluster_name               = var.cluster_name
  cluster_state_bucket       = var.cluster_state_bucket
  application                = var.application
  business-unit              = var.business-unit
  environment-name           = var.environment-name
  infrastructure-support     = var.infrastructure-support
  is-production              = var.is-production
  team_name                  = var.team_name
  elasticsearch-domain       = "probation-search"
  namespace                  = var.namespace
  elasticsearch_version      = "7.9"
  aws-es-proxy-replica-count = 2
  instance_type              = "t2.medium.elasticsearch"
}

module "es_snapshots_s3_bucket" {
  source                 = "github.com/ministryofjustice/cloud-platform-terraform-s3-bucket?ref=4.5"
  team_name              = var.team_name
  acl                    = "private"
  versioning             = false
  business-unit          = var.business-unit
  application            = var.application
  is-production          = var.is-production
  environment-name       = var.environment-name
  infrastructure-support = var.infrastructure-support
  namespace              = var.namespace

  providers = {
    aws = aws.london
  }
}
