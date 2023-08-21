module "cp_test_queue" {
  source = "github.com/ministryofjustice/cloud-platform-terraform-sqs?ref=4.12.0"

  # Queue configuration
  sqs_name                  = "cp-test-queue"
  encrypt_sqs_kms           = "false"
  message_retention_seconds = 1209600

  # Tags
  business_unit          = var.business_unit
  application            = var.application
  is_production          = var.is_production
  team_name              = "crimeapps" # also used for naming the queue
  namespace              = var.namespace
  environment_name       = var.environment_name
  infrastructure_support = var.infrastructure_support

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
