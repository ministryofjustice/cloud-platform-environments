resource "aws_ssm_parameter" "rds_database_name" {
  type        = "SecureString"
  name        = "/${var.namespace}/rds-database-name"
  value       = module.hmpps_assess_risks_and_needs_integrations_dev_rds.database_name
  description = "Database name exported to use in a Foreign Data Wrapper in another namespace"
  tags        = local.tags
}

resource "aws_ssm_parameter" "rds_database_username" {
  type        = "SecureString"
  name        = "/${var.namespace}/rds-database-username"
  value       = module.hmpps_assess_risks_and_needs_integrations_dev_rds.database_username
  description = "Database username exported to use in a Foreign Data Wrapper in another namespace"
  tags        = local.tags
}

resource "aws_ssm_parameter" "rds_database_password" {
  type        = "SecureString"
  name        = "/${var.namespace}/rds-database-password"
  value       = module.hmpps_assess_risks_and_needs_integrations_dev_rds.database_password
  description = "Database password exported to use in a Foreign Data Wrapper in another namespace"
  tags        = local.tags
}

resource "aws_ssm_parameter" "rds_instance_address" {
  type        = "SecureString"
  name        = "/${var.namespace}/rds-instance-address"
  value       = module.hmpps_assess_risks_and_needs_integrations_dev_rds.rds_instance_address
  description = "Database address exported to use in a Foreign Data Wrapper in another namespace"
  tags        = local.tags
}

resource "aws_ssm_parameter" "rds_instance_port" {
  type        = "SecureString"
  name        = "/${var.namespace}/rds-instance-port"
  value       = module.hmpps_assess_risks_and_needs_integrations_dev_rds.rds_instance_port
  description = "Database port exported to use in a Foreign Data Wrapper in another namespace"
  tags        = local.tags
}

# Resources for the SQS queues used with the namespace
locals {
  sqs_irsa_policies = {
    (module.arns_coordinator_queue.sqs_name)             = module.arns_coordinator_queue.irsa_policy_arn
    (module.arns_coordinator_dead_letter_queue.sqs_name) = module.arns_coordinator_dead_letter_queue.irsa_policy_arn
  }
}

resource "aws_ssm_parameter" "tf-outputs-sqs-irsa-policies" {
  for_each = local.sqs_irsa_policies
  type     = "String"
  name     = "/${var.namespace}/sqs/${each.key}/irsa-policy-arn"
  value    = each.value
  tags     = local.tags
}
