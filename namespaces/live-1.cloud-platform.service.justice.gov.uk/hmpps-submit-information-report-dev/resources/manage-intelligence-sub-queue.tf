module "information_report_submissions_queue" {
  source = "github.com/ministryofjustice/cloud-platform-terraform-sqs?ref=4.1"

  environment-name          = var.environment-name
  team_name                 = var.team_name
  infrastructure-support    = var.infrastructure-support
  application               = var.application
  sqs_name                  = "information_report_submissions_queue"
  encrypt_sqs_kms           = "true"
  message_retention_seconds = 1209600
  namespace                 = var.namespace

  redrive_policy = <<EOF
  {
    "deadLetterTargetArn": "${module.information_report_submissions_dead_letter_queue.sqs_arn}","maxReceiveCount": 1
  }
  EOF

  providers = {
    aws = aws.london
  }
}

module "information_report_submissions_dead_letter_queue" {
  source = "github.com/ministryofjustice/cloud-platform-terraform-sqs?ref=4.1"

  environment-name       = var.environment-name
  team_name              = var.team_name
  infrastructure-support = var.infrastructure-support
  application            = var.application
  sqs_name               = "information_report_submissions_queue_dl"
  encrypt_sqs_kms        = "true"
  namespace              = var.namespace

  providers = {
    aws = aws.london
  }
}

resource "kubernetes_secret" "information_report_submissions_queue" {
  metadata {
    name      = "information-report-submission-sqs"
    namespace = var.namespace
  }

  data = {
    access_key_id     = module.information_report_submissions_queue.access_key_id
    secret_access_key = module.information_report_submissions_queue.secret_access_key
    sqs_url           = module.information_report_submissions_queue.sqs_id
    sqs_arn           = module.information_report_submissions_queue.sqs_arn
    sqs_name          = module.information_report_submissions_queue.sqs_name
  }
}

resource "kubernetes_secret" "ir_submissions_queue" {
  metadata {
    name      = "information-report-submission-sqs"
    namespace = "manage-intelligence-dev"
  }

  data = {
    access_key_id     = module.information_report_submissions_queue.access_key_id
    secret_access_key = module.information_report_submissions_queue.secret_access_key
    sqs_url           = module.information_report_submissions_queue.sqs_id
    sqs_arn           = module.information_report_submissions_queue.sqs_arn
    sqs_name          = module.information_report_submissions_queue.sqs_name
  }
}

resource "kubernetes_secret" "information_report_submissions_dead_letter_queue" {
  metadata {
    name      = "information-report-submission-sqs-dl"
    namespace = var.namespace
  }

  data = {
    access_key_id     = module.information_report_submissions_dead_letter_queue.access_key_id
    secret_access_key = module.information_report_submissions_dead_letter_queue.secret_access_key
    sqs_url           = module.information_report_submissions_dead_letter_queue.sqs_id
    sqs_arn           = module.information_report_submissions_dead_letter_queue.sqs_arn
    sqs_name          = module.information_report_submissions_dead_letter_queue.sqs_name
  }
}

resource "kubernetes_secret" "ir_submissions_dead_letter_queue" {
  metadata {
    name      = "information-report-submission-sqs-dl"
    namespace = "manage-intelligence-dev"
  }

  data = {
    access_key_id     = module.information_report_submissions_dead_letter_queue.access_key_id
    secret_access_key = module.information_report_submissions_dead_letter_queue.secret_access_key
    sqs_url           = module.information_report_submissions_dead_letter_queue.sqs_id
    sqs_arn           = module.information_report_submissions_dead_letter_queue.sqs_arn
    sqs_name          = module.information_report_submissions_dead_letter_queue.sqs_name
  }
}
