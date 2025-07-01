# Data source for OpenSearch domain
data "aws_opensearch_domain" "live_app_logs" {
  domain_name = "cp-live-app-logs"
}

# Data source for IAM role
data "aws_iam_role" "os_access_role_app_logs" {
  name = "opensearch-access-role-app-logs"
}

provider "opensearch" {
  alias               = "app_logs"
  url                 = "https://${data.aws_opensearch_domain.live_app_logs.endpoint}"
  aws_assume_role_arn = data.aws_iam_role.os_access_role_app_logs.arn
  sign_aws_requests   = true
  healthcheck         = false
  sniff               = false
}