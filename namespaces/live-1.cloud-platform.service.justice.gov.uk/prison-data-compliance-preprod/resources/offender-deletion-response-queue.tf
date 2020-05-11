module "offender_deletion_response_queue" {
  source = "github.com/ministryofjustice/cloud-platform-terraform-sqs?ref=4.0"

  environment-name           = var.environment-name
  team_name                  = var.team_name
  infrastructure-support     = var.infrastructure-support
  application                = var.application
  sqs_name                   = "offender_deletion_response_queue"
  encrypt_sqs_kms            = "true"
  visibility_timeout_seconds = 300
  message_retention_seconds  = 1209600

  redrive_policy = <<EOF
  {
    "deadLetterTargetArn": "${module.offender_deletion_response_dead_letter_queue.sqs_arn}","maxReceiveCount": 3
  }
  EOF

  providers = {
    aws = aws.london
  }
}

module "offender_deletion_response_dead_letter_queue" {
  source = "github.com/ministryofjustice/cloud-platform-terraform-sqs?ref=4.0"

  environment-name       = var.environment-name
  team_name              = var.team_name
  infrastructure-support = var.infrastructure-support
  application            = var.application
  sqs_name               = "offender_deletion_response_queue_dl"
  encrypt_sqs_kms        = "true"

  providers = {
    aws = aws.london
  }
}

resource "kubernetes_secret" "offender_deletion_response_queue" {
  metadata {
    name      = "offender-deletion-response-sqs"
    namespace = var.namespace
  }

  data = {
    access_key_id     = module.offender_deletion_response_queue.access_key_id
    secret_access_key = module.offender_deletion_response_queue.secret_access_key
    sqs_od_resp_url   = module.offender_deletion_response_queue.sqs_id
    sqs_od_resp_arn   = module.offender_deletion_response_queue.sqs_arn
    sqs_od_resp_name  = module.offender_deletion_response_queue.sqs_name
  }
}

resource "kubernetes_secret" "offender_deletion_response_dead_letter_queue" {
  metadata {
    name      = "offender-deletion-response-sqs-dl"
    namespace = var.namespace
  }

  data = {
    access_key_id     = module.offender_deletion_response_dead_letter_queue.access_key_id
    secret_access_key = module.offender_deletion_response_dead_letter_queue.secret_access_key
    sqs_od_resp_url   = module.offender_deletion_response_dead_letter_queue.sqs_id
    sqs_od_resp_arn   = module.offender_deletion_response_dead_letter_queue.sqs_arn
    sqs_od_resp_name  = module.offender_deletion_response_dead_letter_queue.sqs_name
  }
}
