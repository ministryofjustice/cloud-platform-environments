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

resource "random_password" "readonly-password" {
  length  = 16
  special = false
}

resource "postgresql_role" "readonly_role" {
  login    = true
  name     = "readonly-ddatabase-user"
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

variable "snapshotdb_username" {
  default = module.rds-instance.database_username
}

variable "snapshotdb_password" {
  default = module.rds-instance.database_password
}

variable "snapshotdb_endpoint" {
  default = module.rds-snapshot.rds_instance_endpoint
}

variable "snapshotdb_instance" {
  default = module.rds-snapshot.database_name
}

resource "kubernetes_secret" "rds-snapshot" {
  metadata {
    name      = "rds-snapshot-staging"
    namespace = var.dev_namespace
  }

  data = {
    access_key_id     = module.rds-instance.access_key_id
    secret_access_key = module.rds-instance.secret_access_key
    url               = "postgres://${var.snapshotdb_username}:${var.snapshotdb_password}@${var.snapshotdb_endpoint}/${var.snapshotdb_instance}"
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

