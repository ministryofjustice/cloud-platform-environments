module "extract-placed-topic" {
  source = "github.com/ministryofjustice/cloud-platform-terraform-sns-topic?ref=4.4"

  team_name          = var.team_name
  topic_display_name = "extract-placed-topic"

  providers = {
    aws = aws.london
  }

}

data "aws_iam_policy_document" "extract_placed_topic_policy" {

  statement {
    sid     = "WMTS3ToTopic"
    effect  = "Allow"
    actions = ["SNS:Publish"]
    principals {
      type        = "Service"
      identifiers = ["s3.amazonaws.com"]
    }
    condition {
      variable = "aws:SourceArn"
      test     = "ArnEquals"
      values   = [module.hmpps-workload-prod-s3-extract-bucket.bucket_arn]
    }
    resources = [module.extract-placed-topic.topic_arn]
  }
}

resource "aws_sns_topic_policy" "extract_placed_topic_policy" {
  arn = module.extract-placed-topic.topic_arn
  policy    = data.aws_iam_policy_document.extract_placed_topic_policy.json
}

resource "kubernetes_secret" "extract-placed-topic-secret" {
  metadata {
    name      = "extract-placed-topic-instance-output"
    namespace = var.namespace
  }

  data = {
    access_key_id     = module.extract-placed-topic.access_key_id
    secret_access_key = module.extract-placed-topic.secret_access_key
    topic_arn         = module.extract-placed-topic.topic_arn
  }
}



