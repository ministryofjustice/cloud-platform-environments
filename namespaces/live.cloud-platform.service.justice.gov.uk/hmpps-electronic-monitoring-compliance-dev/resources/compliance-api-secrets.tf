resource "kubernetes_secret" "rds" {
  metadata {
    name      = "rds-postgresql-instance-output"
    namespace = var.namespace
  }

  data = {
    rds_instance_endpoint = module.rds.rds_instance_endpoint
    database_name         = module.rds.database_name
    database_username     = module.rds.database_username
    database_password     = module.rds.database_password
    rds_instance_address  = module.rds.rds_instance_address
  }
}

# Configmap to store non-sensitive data related to the RDS instance
resource "kubernetes_config_map" "rds" {
  metadata {
    name      = "rds-postgresql-instance-output"
    namespace = var.namespace
  }

  data = {
    database_name = module.rds.database_name
    db_identifier = module.rds.db_identifier
  }
}

resource "kubernetes_secret" "irsa" {
  metadata {
    name      = "${module.hmpps_electronic_monitoring_compliance_api.application}-irsa-output"
    namespace = var.namespace
  }
  
  data = {
    role           = module.irsa.role_name
    serviceaccount = module.irsa.service_account.name
  }
}

# Configmap to store non-sensitive data related to the Electronic Monitoring Data Store
resource "kubernetes_config_map" "datastore" {
  metadata {
    name      = "${module.hmpps_electronic_monitoring_compliance_api.application}-datastore"
    namespace = var.namespace
  }

  data = {
    assume_role_arn = var.datastore_role_arn
  }
}
