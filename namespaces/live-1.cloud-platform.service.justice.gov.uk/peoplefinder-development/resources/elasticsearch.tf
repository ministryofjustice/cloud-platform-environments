################################################################################
# Peoplefinder
# Application Elasticsearch cluster
#################################################################################

# For logging elastic search on cloudwatch
resource "aws_cloudwatch_log_group" "peoplefinder_cloudwatch_log_group" {
  name              = "/aws/aes/domains/peoplefinder-development-es/application-logs"
  retention_in_days = 365

  tags = {
    Environment = "development"
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
  policy_name     = "peoplefinder-dev-elasticsearch-log-publishing-policy"
}