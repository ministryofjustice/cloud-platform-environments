# This runs in the Preprod namespace and writes a secret containing
# Preprod DB credentials into the prod namespace. The prod-replica restore CronJob
# can then read this secret directly

resource "kubernetes_secret" "preprod_rds_credentials_in_prod" {
  metadata {
    name      = "preprod-rds-credentials"
    namespace = "hmpps-managing-prisoner-apps-prod"
  }

  data = {
    rds_instance_endpoint = module.rds.rds_instance_endpoint
    database_name         = module.rds.database_name
    database_username     = module.rds.database_username
    database_password     = module.rds.database_password
  }
}