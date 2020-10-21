module "cp_test_queue" {
  source = "github.com/ministryofjustice/cloud-platform-terraform-sqs?ref=4.1"

  environment-name          = "development"
  team_name                 = "crimeapps"
  application               = "crimeapps"
  sqs_name                  = "cp-test-queue"
  infrastructure-support    = "example-team@digtal.justice.gov.uk"
  encrypt_sqs_kms           = "false"
  message_retention_seconds = 1209600
  namespace                 = var.namespace

  providers = {
    aws = aws.london
  }
}

resource "aws_sqs_queue_policy" "cp_test_queue" {
  queue_url = module.cp_test_queue.sqs_id

  policy = <<EOF
  {
    "Version": "2012-10-17",
    "Id": "${module.cp_test_queue.sqs_arn}/SQSDefaultPolicy",
    "Statement":
      [
        {
          "Sid": "first",
          "Effect": "Allow",
          "Resource": "${module.cp_test_queue.sqs_arn}",
          "Action": "SQS:*"
        }
      ]
  }
   EOF
}

resource "kubernetes_secret" "cp_test_queue" {
  metadata {
    name      = "cp-test-instance-output"
    namespace = "laa-court-data-adaptor-dev"
  }

  data = {
    access_key_id     = module.cp_test_queue.access_key_id
    secret_access_key = module.cp_test_queue.secret_access_key
    sqs_id            = module.cp_test_queue.sqs_id
    sqs_arn           = module.cp_test_queue.sqs_arn
    sqs_name          = module.cp_test_queue.sqs_name
  }
}
