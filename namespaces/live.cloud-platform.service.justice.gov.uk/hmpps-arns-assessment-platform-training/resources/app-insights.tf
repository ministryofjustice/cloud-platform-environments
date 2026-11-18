# Same parameter the hmpps-template module reads for application_insights_instance = "dev"
data "aws_ssm_parameter" "application_insights_key" {
  name = "/application_insights/key-dev"
}
