module "cp_test_s3_bucket" {
  source = "github.com/ministryofjustice/cloud-platform-terraform-s3-bucket?ref=4.6"
  acl    = "private"

  team_name              = var.team_name
  business-unit          = var.business_unit
  application            = var.application
  is-production          = var.is_production
  environment-name       = var.environment_name
  infrastructure-support = var.infrastructure_support
  namespace              = var.namespace

  providers = {
    aws = aws.london
  }

}

module "cp_test_s3_object_created_topic" {
  source = "github.com/ministryofjustice/cloud-platform-terraform-sns-topic?ref=4.2"

  team_name          = var.team_name
  topic_display_name = "cp-test-s3-object-created-topic"

  providers = {
    aws = aws.london
  }
}

resource "aws_sns_topic_policy" "cp_test_s3_object_created_policy" {
  arn = module.cp_test_s3_object_created_topic.topic_arn

  policy = <<POLICY
{
    "Version":"2012-10-17",
    "Statement":[{
        "Effect": "Allow",
        "Principal": { "Service": "s3.amazonaws.com" },
        "Action": "SNS:Publish",
        "Resource": "arn:aws:sns:*:*:"${module.cp_test_s3_object_created_topic.topic_arn}",
        "Condition":{
            "ArnLike":{"aws:SourceArn":"${module.cp_test_s3_bucket.bucket_arn}"}
        }
    }]
}
POLICY
}

resource "aws_s3_bucket_notification" "bucket_notification" {
  bucket = module.cp_test_s3_bucket.bucket_name

  topic {
    topic_arn     = module.cp_test_s3_object_created_topic.topic_arn
    events        = ["s3:ObjectCreated:*"]
    filter_suffix = ".log"
  }
}


module "cp_test_s3_object_created_queue" {
  source = "github.com/ministryofjustice/cloud-platform-terraform-sqs?ref=4.3"

  environment-name       = var.environment_name
  team_name              = var.team_name
  infrastructure-support = var.infrastructure_support
  application            = var.application
  sqs_name               = "cp-test-s3-bucket-created-queue"
  encrypt_sqs_kms        = "false"
  namespace              = var.namespace

  redrive_policy = <<EOF
  {
    "deadLetterTargetArn": "${module.s3_bucket_dead_letter_queue.sqs_arn}","maxReceiveCount": 1
  }

EOF


  providers = {
    aws = aws.london
  }
}


module "s3_bucket_dead_letter_queue" {
  source = "github.com/ministryofjustice/cloud-platform-terraform-sqs?ref=4.3"

  environment-name       = var.environment_name
  team_name              = var.team_name
  infrastructure-support = var.infrastructure_support
  application            = var.application
  sqs_name               = "reponses-for-cp-test-s3-bucket-dlq"
  encrypt_sqs_kms        = "false"
  namespace              = var.namespace

  providers = {
    aws = aws.london
  }
}

resource "aws_sqs_queue_policy" "s3_bucket_created_queue_policy" {
  queue_url = module.cp_test_s3_object_created_queue.sqs_id

  policy = <<EOF
  {
    "Version": "2012-10-17",
    "Id": "${module.cp_test_s3_object_created_queue.sqs_arn}/SQSDefaultPolicy",
    "Statement":
      [
        {
          "Effect": "Allow",
          "Principal": {"AWS": "*"},
          "Resource": "${module.cp_test_s3_object_created_queue.sqs_arn}",
          "Action": "SQS:SendMessage",
          "Condition":
            {
              "ArnEquals":
                {
                  "aws:SourceArn": "${module.cp_test_s3_object_created_topic.topic_arn}"
                }
              }
        }
      ]
  }

EOF

}


resource "aws_sns_topic_subscription" "cp_test_s3_object_created" {
  provider  = aws.london
  topic_arn = module.cp_test_s3_object_created_topic.topic_arn
  protocol  = "sqs"
  endpoint  = module.cp_test_s3_object_created_queue.sqs_arn
}



resource "kubernetes_secret" "s3_bucket" {
  metadata {
    name      = "s3"
    namespace = var.namespace
  }

  data = {
    access_key_id     = module.cp_test_s3_bucket.access_key_id
    secret_access_key = module.cp_test_s3_bucket.secret_access_key
  }
}


resource "kubernetes_secret" "cp_test_s3_messaging" {
  metadata {
    name      = "pk-staging-s3-messaging"
    namespace = var.namespace
  }
  data = {
    access_key_id     = module.cp_test_s3_object_created_topic.access_key_id
    secret_access_key = module.cp_test_s3_object_created_topic.secret_access_key
    topic_arn         = module.cp_test_s3_object_created_topic.topic_arn
    cp_test_sqs_name      = module.cp_test_s3_object_created_queue.sqs_name
    cp_test_sqs_url       = module.cp_test_s3_object_created_queue.sqs_id
    cp_test_sqs_arn       = module.cp_test_s3_object_created_queue.sqs_arn
  }
}