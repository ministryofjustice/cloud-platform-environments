################################################################################
# Peoplefinder
# Application Elasticsearch cluster
#################################################################################

# For logging elastic search on cloudwatch
resource "aws_cloudwatch_log_group" "peoplefinder_cloudwatch_log_group" {
  name              = "/aws/aes/domains/peoplefinder-production-es/application-logs"
  retention_in_days = 60

  tags = {
    Environment = "production"
    Application = "peoplefinder"
  }
}

data "aws_iam_policy_document" "elasticsearch_log_publishing_policy_doc" {
  statement {
    actions = [
      "logs:CreateLogStream",
      "logs:PutLogEvents",
      "logs:PutLogEventsBatch",
    ]

    resources = [aws_cloudwatch_log_group.peoplefinder_cloudwatch_log_group.arn]

    principals {
      identifiers = ["es.amazonaws.com"]
      type        = "Service"
    }
  }
}

resource "aws_cloudwatch_log_resource_policy" "elasticsearch_log_publishing_policy" {
  policy_document = data.aws_iam_policy_document.elasticsearch_log_publishing_policy_doc.json
  policy_name     = "peoplefinder-prod-elasticsearch-log-publishing-policy"
}

# Elastic search module
module "peoplefinder_es" {
  source                     = "github.com/ministryofjustice/cloud-platform-terraform-elasticsearch?ref=4.2.0"
  vpc_name                   = var.vpc_name
  eks_cluster_name           = var.eks_cluster_name
  application                = var.application
  business-unit              = var.business_unit
  environment-name           = var.environment
  infrastructure-support     = var.infrastructure-support
  is-production              = var.is_production
  team_name                  = var.team_name
  elasticsearch-domain       = "es"
  namespace                  = var.namespace
  elasticsearch_version      = "7.9"
  aws-es-proxy-replica-count = 2
  instance_type              = "t3.medium.elasticsearch"
  ebs_iops                   = 0
  ebs_volume_type            = "gp2"

  log_publishing_application_cloudwatch_log_group_arn = aws_cloudwatch_log_group.peoplefinder_cloudwatch_log_group.arn
  log_publishing_application_enabled                  = true
  encryption_at_rest                                  = true
  node_to_node_encryption_enabled                     = true
  domain_endpoint_enforce_https                       = true

  advanced_options = {
    override_main_response_version = true
  }
}
