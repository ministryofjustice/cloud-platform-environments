
module "evidencelibrary_rds" {
  source        = "github.com/ministryofjustice/cloud-platform-terraform-rds-instance?ref=5.16.7"
  cluster_name  = var.cluster_name
  team_name     = var.team_name
  business-unit = var.business_unit
  application   = var.application
  is-production = var.is_production
  namespace     = var.namespace

  # enable performance insights
  performance_insights_enabled = true

  # change the postgres version as you see fit.
  db_engine_version      = var.db_engine_version
  environment-name       = var.environment
  infrastructure-support = var.infrastructure_support

  # rds_family should be one of: postgres9.4, postgres9.5, postgres9.6, postgres10, postgres11
  # Pick the one that defines the postgres version the best
  rds_family = var.rds-family

  # use "allow_major_version_upgrade" when upgrading the major version of an engine
  #allow_major_version_upgrade = "true"

  providers = {
    # Can be either "aws.london" or "aws.ireland"
    aws = aws.london
  }
}

resource "kubernetes_secret" "evidencelibrary_rds" {
  metadata {
    name      = "evidencelibrary-rds-instance-output"
    namespace = var.namespace
  }

  data = {
    rds_instance_endpoint = module.evidencelibrary_rds.rds_instance_endpoint
    database_name         = module.evidencelibrary_rds.database_name
    database_username     = module.evidencelibrary_rds.database_username
    database_password     = module.evidencelibrary_rds.database_password
    rds_instance_address  = module.evidencelibrary_rds.rds_instance_address
    access_key_id         = module.evidencelibrary_rds.access_key_id
    secret_access_key     = module.evidencelibrary_rds.secret_access_key
    url                   = "Host=${module.evidencelibrary_rds.rds_instance_address};Port=5432;Database=${module.evidencelibrary_rds.database_name};Username=${module.evidencelibrary_rds.database_username};Password=${module.evidencelibrary_rds.database_password};SSL Mode=Prefer;Trust Server Certificate=true;"
  }
}

module "evidenceidentity_rds" {
  source        = "github.com/ministryofjustice/cloud-platform-terraform-rds-instance?ref=5.16.7"
  cluster_name  = var.cluster_name
  team_name     = var.team_name
  business-unit = var.business_unit
  application   = var.application
  is-production = var.is_production
  namespace     = var.namespace

  # enable performance insights
  performance_insights_enabled = true

  # change the postgres version as you see fit.
  db_engine_version      = var.db_engine_version
  environment-name       = var.environment
  infrastructure-support = var.infrastructure_support

  # rds_family should be one of: postgres9.4, postgres9.5, postgres9.6, postgres10, postgres11
  # Pick the one that defines the postgres version the best
  rds_family = var.rds-family

  # use "allow_major_version_upgrade" when upgrading the major version of an engine
  #allow_major_version_upgrade = "true"

  providers = {
    # Can be either "aws.london" or "aws.ireland"
    aws = aws.london
  }
}

resource "kubernetes_secret" "evidenceidentity_rds" {
  metadata {
    name      = "evidenceidentity-rds-instance-output"
    namespace = var.namespace
  }

  data = {
    rds_instance_endpoint = module.evidenceidentity_rds.rds_instance_endpoint
    database_name         = module.evidenceidentity_rds.database_name
    database_username     = module.evidenceidentity_rds.database_username
    database_password     = module.evidenceidentity_rds.database_password
    rds_instance_address  = module.evidenceidentity_rds.rds_instance_address
    access_key_id         = module.evidenceidentity_rds.access_key_id
    secret_access_key     = module.evidenceidentity_rds.secret_access_key
    url                   = "Host=${module.evidenceidentity_rds.rds_instance_address};Port=5432;Database=${module.evidenceidentity_rds.database_name};Username=${module.evidenceidentity_rds.database_username};Password=${module.evidenceidentity_rds.database_password};SSL Mode=Prefer;Trust Server Certificate=true;"
  }
}