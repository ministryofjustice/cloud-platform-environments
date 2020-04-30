module "rds-instance" {
  source = "github.com/ministryofjustice/cloud-platform-terraform-rds-instance?ref=5.3"

  cluster_name         = var.cluster_name
  cluster_state_bucket = var.cluster_state_bucket

  application            = var.application
  environment-name       = var.environment-name
  is-production          = var.is-production
  infrastructure-support = var.infrastructure-support
  team_name              = var.team_name
  force_ssl              = "false"

  providers = {
    aws = aws.london
  }
}

provider "postgresql" {
  host             = module.rds-instance.rds_instance_endpoint
  database         = module.rds-instance.database_name
  username         = module.rds-instance.database_username
  password         = module.rds-instance.database_password
  expected_version = "10.6"
  sslmode          = "require"
  connect_timeout  = 15
}

resource "random_password" "readonly-password" {
  length  = 16
  special = false
}

resource "kubernetes_secret" "rds-instance" {
  metadata {
    name      = "rds-instance-hmpps-book-secure-move-api-staging"
    namespace = var.namespace
  }

  data = {
    access_key_id     = module.rds-instance.access_key_id
    secret_access_key = module.rds-instance.secret_access_key
    url               = "postgres://${module.rds-instance.database_username}:${module.rds-instance.database_password}@${module.rds-instance.rds_instance_endpoint}/${module.rds-instance.database_name}"
  }
}
