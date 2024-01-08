data "aws_ssm_parameter" "court-case-events-topic-arn" {
  name = "/court-probation-prod/topic-arn"
}

data "aws_ssm_parameter" "hmpps-domain-events-topic-arn" {
  name = "/hmpps-domain-events-prod/topic-arn"
}

data "aws_ssm_parameter" "court-probation-prod-rds-instance-endpoint" {
  name = "/court-probation-prod/court_case_service_rds/rds_instance_endpoint"
}

data "aws_ssm_parameter" "court-probation-prod-rds-database-name" {
  name = "/court-probation-prod/court_case_service_rds/database_name"
}

data "aws_ssm_parameter" "court-probation-prod-rds-database-username" {
  name = "/court-probation-prod/court_case_service_rds/database_username"
}

data "aws_ssm_parameter" "court-probation-prod-rds-database-password" {
  name = "/court-probation-prod/court_case_service_rds/database_password"
}

data "aws_ssm_parameter" "court-probation-prod-rds-instance-address" {
  name = "/court-probation-prod/court_case_service_rds/rds_instance_address"
}

data "aws_ssm_parameter" "court-probation-prod-rds-url" {
  name = "/court-probation-prod/court_case_service_rds/url"
}