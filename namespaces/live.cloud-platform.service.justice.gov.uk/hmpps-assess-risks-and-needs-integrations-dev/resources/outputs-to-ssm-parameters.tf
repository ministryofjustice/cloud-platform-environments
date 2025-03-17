resource "aws_ssm_parameter" "rds_database_name" {
  type        = "String"
  name        = "/${var.namespace}/rds-database-name"
  value       = module.hmpps_assess_risks_and_needs_integrations_dev_rds.database_name
  description = "Database name exported to use in a Foreign Data Wrapper in another namespace"
  tags        = local.tags
}

resource "aws_ssm_parameter" "rds_database_username" {
  type        = "String"
  name        = "/${var.namespace}/rds-database-username"
  value       = module.hmpps_assess_risks_and_needs_integrations_dev_rds.database_username
  description = "Database username exported to use in a Foreign Data Wrapper in another namespace"
  tags        = local.tags
}

resource "aws_ssm_parameter" "rds_database_password" {
  type        = "String"
  name        = "/${var.namespace}/rds-database-password"
  value       = module.hmpps_assess_risks_and_needs_integrations_dev_rds.database_password
  description = "Database password exported to use in a Foreign Data Wrapper in another namespace"
  tags        = local.tags
}

resource "aws_ssm_parameter" "rds_instance_address" {
  type        = "String"
  name        = "/${var.namespace}/rds-instance-address"
  value       = module.hmpps_assess_risks_and_needs_integrations_dev_rds.database_password
  description = "Database address exported to use in a Foreign Data Wrapper in another namespace"
  tags        = local.tags
}

resource "aws_ssm_parameter" "rds_instance_port" {
  type        = "String"
  name        = "/${var.namespace}/rds-instance-port"
  value       = module.hmpps_assess_risks_and_needs_integrations_dev_rds.database_password
  description = "Database port exported to use in a Foreign Data Wrapper in another namespace"
  tags        = local.tags
}
