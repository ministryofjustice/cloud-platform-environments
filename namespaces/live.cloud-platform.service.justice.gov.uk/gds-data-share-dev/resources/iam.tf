# provide a policy to the gds AWS account to be able to read these queues.
resource "aws_sqs_queue_policy" "gds_data_share_queue_policy" {
  queue_url = module.gds_data_share_queue.sqs_id

  policy = <<EOF
  {
    "Version":"2012-10-17",
    "Id":"${module.gds_data_share_queue.sqs_arn}/SQSDefaultPolicy",
    "Statement":[
       {
          "Effect":"Allow",
          "Principal":{
             "AWS":"*"
          },
          "Resource":"${module.gds_data_share_queue.sqs_arn}",
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
          "Resource":"${module.gds_data_share_queue.sqs_arn}"
       }
    ]
 }

 EOF

}

resource "aws_sqs_queue_policy" "gds_data_share_dlq_policy" {
  queue_url = module.gds_data_share_dlq.sqs_id

  policy = <<EOF
  {
    "Version":"2012-10-17",
    "Id":"${module.gds_data_share_dlq.sqs_arn}/SQSDefaultPolicy",
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
          "Resource":"${module.gds_data_share_dlq.sqs_arn}"
       }
    ]
 }

 EOF

}

