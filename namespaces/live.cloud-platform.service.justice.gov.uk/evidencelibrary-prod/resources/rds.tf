module "evidencelibrary_rds" {
  source                 = "github.com/ministryofjustice/cloud-platform-terraform-rds-instance?ref=6.0.0"
  vpc_name               = var.vpc_name
  team_name              = var.team_name
  business_unit          = var.business_unit
  application            = var.application
  is_production          = var.is_production
  environment_name       = var.environment
  infrastructure_support = var.infrastructure_support
  namespace              = var.namespace

  # If the rds_name is not specified a random name will be generated ( cp-* )
  # Changing the RDS name requires the RDS to be re-created (destroy + create)
  # rds_name             = "my-rds-name"

  # enable performance insights
  performance_insights_enabled = true

  # change the postgres version as you see fit.
  db_engine_version = var.db_engine_version

  # change the instance class as you see fit.
  db_instance_class = var.db_instance_class

  # rds_family should be one of: postgres9.4, postgres9.5, postgres9.6, postgres10, postgres11, postgres12, postgres13
  # Pick the one that defines the postgres version the best
  rds_family = var.rds-family

  # Some engines can't apply some parameters without a reboot(ex postgres9.x cant apply force_ssl immediate).
  # You will need to specify "pending-reboot" here, as default is set to "immediate".
  # db_parameter = [
  #   {
  #     name         = "rds.force_ssl"
  #     value        = "0"
  #     apply_method = "pending-reboot"
  #   }
  # ]

  # use "allow_major_version_upgrade" when upgrading the major version of an engine
  #allow_major_version_upgrade = "false"

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
