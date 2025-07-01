module "opensearch_alert" {

    variable "aws_opensearch_domain" {
        description = "The OpenSearch Cluster for alert creation. Set default to user application logs one."
        type        = string
        default     = "cp-live-app-logs"
    }

    variable "aws_iam_role" {
        description = "AWS IAM role for alert creation. Set detault to user application logs one."
        type        = string
        default     = "opensearch-access-role-app-logs"
    }

    data "aws_opensearch_domain" "live_app_logs" {
        domain_name = var.aws_opensearch_domain
    }

    data "aws_iam_role" "os_access_role_app_logs" {
        name = var.aws_iam_role
    }

    provider "opensearch" {
        alias               = "app_logs"
        url                 = "https://${data.aws_opensearch_domain.live_app_logs.endpoint}"
        aws_assume_role_arn = data.aws_iam_role.os_access_role_app_logs.arn
        sign_aws_requests   = true
        healthcheck         = false
        sniff               = false
    }
}
