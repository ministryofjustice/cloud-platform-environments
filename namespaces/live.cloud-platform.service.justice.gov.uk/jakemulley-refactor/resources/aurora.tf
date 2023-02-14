module "aurora_db" {
  # always check the latest release in Github and set below
  source                 = "github.com/ministryofjustice/cloud-platform-terraform-rds-aurora?ref=use-default-tags"
  vpc_name               = var.vpc_name
  team_name              = var.team_name
  business-unit          = var.business_unit
  application            = var.application
  is-production          = var.is_production
  namespace              = var.namespace
  environment-name       = var.environment
  infrastructure-support = var.infrastructure_support

  # https://registry.terraform.io/providers/hashicorp/aws/2.33.0/docs/resources/rds_cluster#engine
  engine = "aurora-postgresql"

  # https://registry.terraform.io/providers/hashicorp/aws/2.33.0/docs/resources/rds_cluster#engine_version
  # engine_version         = "9.6.9"

  # https://registry.terraform.io/providers/hashicorp/aws/2.33.0/docs/resources/rds_cluster#engine_mode
  # engine_mode            = "serverless"

  # If the rds_name is not specified a random name will be generated ( cloud-platform-* )
  # Changing the RDS name requires the RDS to be re-created (destroy + create)
  # rds_name               = "aurora-test"
  replica_count = 1
  # https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/rds_cluster_instance#instance_class
  # instance_type          = "db.r4.large"
  apply_immediately = true

  # set this for a migrated replica (eg from RDS Postgres)
  # skip_setting_when_migrated = true
}

resource "kubernetes_secret" "aurora_db" {
  metadata {
    name      = "aurora-db-secret"
    namespace = var.namespace
  }

  data = {
    rds_cluster_endpoint        = module.aurora_db.rds_cluster_endpoint
    rds_cluster_reader_endpoint = module.aurora_db.rds_cluster_reader_endpoint
    db_cluster_identifier       = module.aurora_db.db_cluster_identifier
    database_name               = module.aurora_db.database_name
    database_username           = module.aurora_db.database_username
    database_password           = module.aurora_db.database_password
    access_key_id               = module.aurora_db.access_key_id
    secret_access_key           = module.aurora_db.secret_access_key
  }
}
