module "mojforms_rds_aurora" {
  source = "github.com/ministryofjustice/cloud-platform-terraform-rds-aurora?ref=1.2"

  team_name              = var.team_name
  business-unit          = "mojforms"
  application            = "mojforms"
  is-production          = var.is-production
  namespace              = var.namespace
  environment-name       = var.environment-name
  infrastructure-support = var.infrastructure-support
  engine                 = "aurora-postgresql"
  engine_version         = "12.4"
  engine_mode            = "serverless"
  instance_type          = "db.t3.medium"
  storage_encrypted      = true
  apply_immediately      = true
  replica_scale_enabled  = true
  cluster_name           = var.cluster_name
  cluster_state_bucket   = var.cluster_state_bucket

  providers = {
    aws = aws.london
  }
}

resource "kubernetes_secret" "user-datastore-rds-aurora" {
  metadata {
    name      = "rds-aurora-formbuilder-user-datastore-${var.environment-name}"
    namespace = var.namespace
  }

  data = {
    rds_cluster_endpoint        = module.mojforms_rds_aurora.rds_cluster_endpoint
    rds_cluster_reader_endpoint = module.mojforms_rds_aurora.rds_cluster_reader_endpoint
    db_cluster_identifier       = module.mojforms_rds_aurora.db_cluster_identifier
    database_name               = module.mojforms_rds_aurora.database_name
    database_username           = module.mojforms_rds_aurora.database_username
    database_password           = module.mojforms_rds_aurora.database_password

    access_key_id     = module.mojforms_rds_aurora.access_key_id
    secret_access_key = module.mojforms_rds_aurora.secret_access_key
    url               = "postgres://${module.mojforms_rds_aurora.database_username}:${module.mojforms_rds_aurora.database_password}@${module.mojforms_rds_aurora.rds_cluster_endpoint}/${module.mojforms_rds_aurora.database_name}"
  }
}

