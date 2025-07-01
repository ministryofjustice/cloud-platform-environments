provider "opensearch" {
  alias               = "app_logs"
  #url                 = "https://${data.aws_opensearch_domain.live_app_logs.endpoint}"
  #aws_assume_role_arn = data.aws_iam_role.os_access_role_app_logs.arn
}