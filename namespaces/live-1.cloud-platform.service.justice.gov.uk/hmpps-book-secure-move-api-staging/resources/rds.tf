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

resource "postgresql_role" "readonly_role" {
  login    = true
  name     = "readonly-database-user"
  password = random_password.readonly-password.result
}

resource "postgresql_grant" "readonly_tables" {
  database    = "${module.rds-instance.rds_instance_endpoint}/${module.rds-instance.database_name}"
  role        = postgresql_role.readonly_role.name
  schema      = "public"
  object_type = "table"
  privileges  = ["SELECT"]
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

module "rds-snapshot" {
  source = "github.com/ministryofjustice/cloud-platform-terraform-rds-instance?ref=5.3"

  cluster_name         = var.cluster_name
  cluster_state_bucket = var.cluster_state_bucket

  application            = var.application
  environment-name       = var.environment-name
  is-production          = var.is-production
  infrastructure-support = var.infrastructure-support
  team_name              = var.team_name
  force_ssl              = "false"
  snapshot_identifier    = "rds:cloud-platform-e829e612552f9703-2020-03-24-00-59"

  providers = {
    # Can be either "aws.london" or "aws.ireland"
    aws = aws.london
  }
}

resource "kubernetes_secret" "rds-snapshot" {
  metadata {
    name      = "rds-snapshot-staging"
    namespace = var.dev_namespace
  }

  data = {
    access_key_id     = module.rds-instance.access_key_id
    secret_access_key = module.rds-instance.secret_access_key
    url               = "postgres://${module.rds-instance.database_username}:${module.rds-instance.database_password}@${module.rds-snapshot.rds_instance_endpoint}/${module.rds-snapshot.database_name}"
  }
}

resource "kubernetes_secret" "ro-rds-access" {
  metadata {
    name      = "rds-instance-hmpps-book-secure-move-api-staging-ro"
    namespace = var.dev_namespace
  }

  data = {
    url = "postgres://${postgresql_role.readonly_role.name}:${postgresql_role.readonly_role.password}}@${module.rds-instance.rds_instance_endpoint}/${module.rds-instance.database_name}"
  }
}

