module "pre_sentence_service_rds" {
  source                      = "github.com/ministryofjustice/cloud-platform-terraform-rds-instance?ref=5.16.5"
  cluster_name                = var.cluster_name
  team_name                   = var.team_name
  business-unit               = var.business-unit
  namespace                   = var.namespace
  application                 = "pre-sentence-service"
  environment-name            = var.environment-name
  infrastructure-support      = var.infrastructure-support
  rds_family                  = "postgres13"
  db_instance_class           = "db.t3.small"
  db_engine_version           = "13.3"
  allow_major_version_upgrade = false

  providers = {
    aws = aws.london
  }
}

resource "kubernetes_secret" "pre_sentence_service_rds" {
  metadata {
    name      = "pre-sentence-service-rds-instance-output"
    namespace = var.namespace
  }

  data = {
    rds_instance_endpoint = module.pre_sentence_service_rds.rds_instance_endpoint
    database_name         = module.pre_sentence_service_rds.database_name
    database_username     = module.pre_sentence_service_rds.database_username
    database_password     = module.pre_sentence_service_rds.database_password
    rds_instance_address  = module.pre_sentence_service_rds.rds_instance_address
    url                   = "postgres://${module.pre_sentence_service_rds.database_username}:${module.pre_sentence_service_rds.database_password}@${module.pre_sentence_service_rds.rds_instance_endpoint}/${module.pre_sentence_service_rds.database_name}"
    access_key_id         = module.pre_sentence_service_rds.access_key_id
    secret_access_key     = module.pre_sentence_service_rds.secret_access_key
  }
}
