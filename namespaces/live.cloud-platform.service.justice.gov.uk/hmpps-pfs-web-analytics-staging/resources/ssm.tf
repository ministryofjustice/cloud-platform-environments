# Retrieve an SSM parameter containing the IRSA ARNs required to allow publish to SNS topics
data "aws_ssm_parameter" "additional_sns_clients" {
  for_each = toset(var.additional_topic_clients)
  name     = "/${each.value}/irsa/irsa-arn"
}

locals {
  pfs_analytics_client_arns = [for param in data.aws_ssm_parameter.additional_sns_clients : param.value]
}