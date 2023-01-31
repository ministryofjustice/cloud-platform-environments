module "gdx_data_share_queue" {
  source = "github.com/ministryofjustice/cloud-platform-terraform-sqs?ref=4.9.1"

  environment-name          = var.environment-name
  team_name                 = "GDX"
  infrastructure-support    = "michael.willis@digital.justice.gov.uk"
  application               = "GDX Data Share Platform"
  sqs_name                  = "gdx_data_share_queue"
  encrypt_sqs_kms           = "false"
  message_retention_seconds = 600
  namespace                 = var.namespace

  redrive_policy = <<EOF
  {
    "deadLetterTargetArn": "${module.gdx_data_share_dlq.sqs_arn}","maxReceiveCount": 3
  }

EOF


  providers = {
    aws = aws.london
  }
}

module "gdx_data_share_dlq" {
  source = "github.com/ministryofjustice/cloud-platform-terraform-sqs?ref=4.9.1"

  environment-name       = var.environment-name
  team_name              = "GDX"
  infrastructure-support = "michael.willis@digital.justice.gov.uk"
  application            = "GDX Data Share Platform"
  sqs_name               = "gdx_data_share_dlq"
  encrypt_sqs_kms        = "false"
  namespace              = var.namespace

  providers = {
    aws = aws.london
  }
}

# provide a policy to the GDX AWS account to be able to read these queues.
resource "aws_sqs_queue_policy" "gdx_data_share_queue_policy" {
  queue_url = module.gdx_data_share_queue.sqs_id

  policy = <<EOF
 {
   "Version":"2012-10-17",
   "Id":"${module.gdx_data_share_queue.sqs_arn}/SQSDefaultPolicy",
   "Statement":[
      {
         "Effect":"Allow",
         "Principal":{
            "AWS":"*"
         },
         "Resource":"${module.gdx_data_share_queue.sqs_arn}",
         "Action":"SQS:SendMessage",
         "Condition":{
            "ArnEquals":{
               "aws:SourceArn":"${module.hmpps-domain-events.topic_arn}"
            }
         }
      },
      {
         "Effect":"Allow",
         "Principal":{
            "AWS":[
               "arn:aws:iam::776473272850:root"
            ]
         },
         "Action":[
            "SQS:SendMessage",
            "SQS:ReceiveMessage",
            "SQS:DeleteMessage",
            "SQS:GetQueueUrl"
         ],
         "Resource":"${module.gdx_data_share_queue.sqs_arn}"
      }
   ]
}

EOF

}

resource "aws_sqs_queue_policy" "gdx_data_share_queue_policy" {
  queue_url = module.gdx_data_share_dlq.sqs_id

  policy = <<EOF
 {
   "Version":"2012-10-17",
   "Id":"${module.gdx_data_share_dlq.sqs_arn}/SQSDefaultPolicy",
   "Statement":[
      {
         "Effect":"Allow",
         "Principal":{
            "AWS":[
               "arn:aws:iam::776473272850:root"
            ]
         },
         "Action":[
            "SQS:ReceiveMessage",
            "SQS:DeleteMessage",
            "SQS:GetQueueUrl"
         ],
         "Resource":"${module.gdx_data_share_dlq.sqs_arn}"
      }
   ]
}

EOF

}

resource "kubernetes_secret" "gdx_data_share_queue" {
  metadata {
    name      = "sqs-gdx-data-share-secret"
    namespace = var.namespace
  }

  data = {
    sqs_queue_url  = module.gdx_data_share_queue.sqs_id
    sqs_queue_arn  = module.gdx_data_share_queue.sqs_arn
    sqs_queue_name = module.gdx_data_share_queue.sqs_name
  }
}

resource "kubernetes_secret" "gdx_data_share_dlq" {
  metadata {
    name      = "sqs-gdx-datashare-dl-secret"
    namespace = var.namespace
  }

  data = {
    sqs_queue_url  = module.gdx_data_share_queue.sqs_id
    sqs_queue_arn  = module.gdx_data_share_queue.sqs_arn
    sqs_queue_name = module.gdx_data_share_queue.sqs_name
  }
}


resource "aws_sns_topic_subscription" "gdx_data_share_subscription" {
  provider      = aws.london
  topic_arn     = module.hmpps-domain-events.topic_arn
  protocol      = "sqs"
  endpoint      = module.gdx_data_share_queue.sqs_arn
  filter_policy = "{\"eventType\":[\"prison-offender-events.prisoner.received\"]}"
}


