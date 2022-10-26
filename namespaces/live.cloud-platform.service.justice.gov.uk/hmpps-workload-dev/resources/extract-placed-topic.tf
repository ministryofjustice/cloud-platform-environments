module "extract-placed-topic" {
  source = "github.com/carlov20/cloud-platform-terraform-sns-topic?ref=main"

  team_name          = var.team_name
  topic_display_name = "extract-placed-topic"

  providers = {
    aws = aws.london
  }

  policy = <<EOF
  {
    "Version":"2012-10-17",
    "Statement":[{
        "Effect": "Allow",
        "Principal": { "Service": "s3.amazonaws.com" },
        "Action": "SNS:Publish",
        "Resource": "${module.extract-placed-topic.topic_arn}",
        "Condition":{
            "ArnLike":{"aws:SourceArn":"${module.hmpps-workload-dev-s3-extract-bucket.bucket_arn}"}
        }
    }]
  }
    EOF
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



