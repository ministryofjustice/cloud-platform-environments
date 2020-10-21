module "data_compliance_request_queue" {
  source = "github.com/ministryofjustice/cloud-platform-terraform-sqs?ref=4.1"

  environment-name           = var.environment-name
  team_name                  = var.team_name
  infrastructure-support     = var.infrastructure-support
  application                = var.application
  sqs_name                   = "data_compliance_request_queue"
  encrypt_sqs_kms            = "true"
  visibility_timeout_seconds = 1200
  message_retention_seconds  = 1209600
  namespace                  = var.namespace

  redrive_policy = <<EOF
  {
    "deadLetterTargetArn": "${module.data_compliance_request_dead_letter_queue.sqs_arn}","maxReceiveCount": 1
  }
  EOF

  providers = {
    aws = aws.london
  }
}

module "data_compliance_request_dead_letter_queue" {
  source = "github.com/ministryofjustice/cloud-platform-terraform-sqs?ref=4.1"

  environment-name       = var.environment-name
  team_name              = var.team_name
  infrastructure-support = var.infrastructure-support
  application            = var.application
  sqs_name               = "data_compliance_request_queue_dl"
  encrypt_sqs_kms        = "true"
  namespace              = var.namespace

  providers = {
    aws = aws.london
  }
}

resource "kubernetes_secret" "data_compliance_request_queue" {
  metadata {
    name      = "data-compliance-request-sqs"
    namespace = var.namespace
  }

  data = {
    access_key_id     = module.data_compliance_request_queue.access_key_id
    secret_access_key = module.data_compliance_request_queue.secret_access_key
    sqs_dc_req_url    = module.data_compliance_request_queue.sqs_id
    sqs_dc_req_arn    = module.data_compliance_request_queue.sqs_arn
    sqs_dc_req_name   = module.data_compliance_request_queue.sqs_name
  }
}

resource "kubernetes_secret" "data_compliance_request_dead_letter_queue" {
  metadata {
    name      = "data-compliance-request-sqs-dl"
    namespace = var.namespace
  }

  data = {
    access_key_id     = module.data_compliance_request_dead_letter_queue.access_key_id
    secret_access_key = module.data_compliance_request_dead_letter_queue.secret_access_key
    sqs_dc_req_url    = module.data_compliance_request_dead_letter_queue.sqs_id
    sqs_dc_req_arn    = module.data_compliance_request_dead_letter_queue.sqs_arn
    sqs_dc_req_name   = module.data_compliance_request_dead_letter_queue.sqs_name
  }
}
