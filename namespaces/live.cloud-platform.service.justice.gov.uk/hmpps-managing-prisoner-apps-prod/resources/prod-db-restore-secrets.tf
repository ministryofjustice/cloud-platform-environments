#
# This runs in the Prod namespace terraform and writes a secret containing
# Prod DB credentials into the Preprod namespace. The preprod restore CronJob
# (db-restore-cronjob.yaml) can then read this secret directly and uses
# this secret as SOURCE when doing pg_dump from prod

resource "kubernetes_secret" "prod_rds_credentials_in_preprod" {
  metadata {
    name      = "prod-rds-credentials"
    namespace = "hmpps-managing-prisoner-apps-preprod"
  }

  data = {
    rds_instance_endpoint = module.rds.rds_instance_endpoint
    database_name         = module.rds.database_name
    database_username     = module.rds.database_username
    database_password     = module.rds.database_password
  }
}

