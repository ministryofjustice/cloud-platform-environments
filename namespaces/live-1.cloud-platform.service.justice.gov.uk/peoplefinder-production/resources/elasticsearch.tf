################################################################################
# Peoplefinder
# Application Elasticsearch cluster
#################################################################################

# For logging elastic search on cloudwatch
resource "aws_cloudwatch_log_group" "peoplefinder_cloudwatch_log_group" {
  name              = "/aws/aes/domains/peoplefinder-production-es/application-logs"
  retention_in_days = 365

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
  source                 = "github.com/ministryofjustice/cloud-platform-terraform-elasticsearch?ref=3.9.2"
  cluster_name           = var.cluster_name
  application            = "peoplefinder"
  business-unit          = "Central Digital"
  environment-name       = "production"
  infrastructure-support = "people-finder-support@digital.justice.gov.uk"
  is-production          = "true"
  team_name              = "peoplefinder"
  elasticsearch-domain   = "es"
  namespace              = "peoplefinder-production"
  elasticsearch_version  = "6.8"
  instance_type          = "t2.medium.elasticsearch"

  log_publishing_application_cloudwatch_log_group_arn = aws_cloudwatch_log_group.peoplefinder_cloudwatch_log_group.arn
  log_publishing_application_enabled                  = true
}

module "ns_annotation" {
  source              = "github.com/ministryofjustice/cloud-platform-terraform-ns-annotation?ref=0.0.3"
  ns_annotation_roles = [module.peoplefinder_es.aws_iam_role_name]
  namespace           = var.namespace
}
