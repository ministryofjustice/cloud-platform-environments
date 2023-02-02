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
                "aws:SourceArn":"${data.aws_sns_topic.hmpps-domain-events.arn}"
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

resource "aws_sqs_queue_policy" "gdx_data_share_dlq_policy" {
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

