module "secrets_manager" {
  source = "github.com/ministryofjustice/cloud-platform-terraform-secrets-manager?ref=3.0.7"

  eks_cluster_name = var.eks_cluster_name

  secrets = {
    "laa-info-and-advice-datastore-entra-uat" = {
      description             = "Microsoft Entra OAuth2 config for laa-info-and-advice-datastore UAT"
      recovery_window_in_days = 7
      k8s_secret_name         = "laa-info-and-advice-datastore-entra"
    }
  }

  application            = var.application
  business_unit          = var.business_unit
  environment_name       = var.environment
  infrastructure_support = var.infrastructure_support
  is_production          = var.is_production
  namespace              = var.namespace
  team_name              = var.team_name
}

resource "aws_secretsmanager_secret" "rds" {
  name                    = "laa-info-and-advice-datastore-rds-uat"
  description             = "RDS credentials for laa-info-and-advice-datastore UAT"
  recovery_window_in_days = 7
}

resource "aws_secretsmanager_secret_version" "rds" {
  secret_id     = aws_secretsmanager_secret.rds.id
  secret_string = jsonencode({
    username = module.rds.database_username
    password = module.rds.database_password
    host     = module.rds.rds_instance_address
    port     = module.rds.rds_instance_port
    dbname   = module.rds.database_name
  })
}
