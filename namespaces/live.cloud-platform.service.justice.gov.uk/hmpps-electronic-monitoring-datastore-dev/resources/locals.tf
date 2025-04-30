locals {
  tags = {
    business-unit          = var.business_unit
    application            = var.application
    is-production          = var.is_production
    owner                  = var.team_name
    environment-name       = var.environment
    infrastructure-support = var.infrastructure_support
    namespace              = var.namespace
  }
  
  sqs_queues = {
    "Digital-Prison-Services-dev-hmpps_audit_queue" = "hmpps-audit-dev"
  }

  sqs_policies = { for item in data.aws_ssm_parameter.irsa_policy_arns_sqs : item.name => item.value }

  athena_roles = {
    test_general  = "arn:aws:iam::396913731313:role/cmt_read_emds_data_test",
    test_specials = "arn:aws:iam::396913731313:role/specials_cmt_read_emds_data_test",
  }
}
