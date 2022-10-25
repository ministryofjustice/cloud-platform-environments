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
        "Resource": "arn:aws:sns:*:*:s3-event-notification-topic",
        "Condition":{
            "ArnLike":{"aws:SourceArn":"${module.hmpps-workload-dev-s3-extract-bucket.bucket_arn}"}
        }
    }]
  }
    EOF
}



