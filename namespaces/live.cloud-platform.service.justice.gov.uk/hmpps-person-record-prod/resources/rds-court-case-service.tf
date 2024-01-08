resource "kubernetes_secret" "court_case_service_rds" {
  metadata {
    name      = "court-case-service-rds-instance-output"
    namespace = var.namespace
  }

  data = {
    rds_instance_endpoint = data.aws_ssm_parameter.court-probation-prod-rds-instance-endpoint.value
    database_name         = data.aws_ssm_parameter.court-probation-prod-rds-database-name.value
    database_username     = data.aws_ssm_parameter.court-probation-prod-rds-database-username.value
    database_password     = data.aws_ssm_parameter.court-probation-prod-rds-database-password.value
    rds_instance_address  = data.aws_ssm_parameter.court-probation-prod-rds-instance-address.value
    url                   = "postgres://${database_username}:${database_password}@${rds_instance_endpoint}/${database_name}"
  }
}