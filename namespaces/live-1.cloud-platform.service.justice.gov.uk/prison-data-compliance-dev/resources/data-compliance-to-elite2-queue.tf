module "data_compliance_to_elite2_queue" {
  source = "github.com/ministryofjustice/cloud-platform-terraform-sqs?ref=4.0"

  environment-name           = var.environment-name
  team_name                  = var.team_name
  infrastructure-support     = var.infrastructure-support
  application                = var.application
  sqs_name                   = "data_compliance_to_elite2_queue"
  encrypt_sqs_kms            = "true"
  visibility_timeout_seconds = 300
  message_retention_seconds  = 1209600

  redrive_policy = <<EOF
  {
    "deadLetterTargetArn": "${module.data_compliance_to_elite2_dead_letter_queue.sqs_arn}","maxReceiveCount": 3
  }
  EOF

  providers = {
    aws = aws.london
  }
}

module "data_compliance_to_elite2_dead_letter_queue" {
  source = "github.com/ministryofjustice/cloud-platform-terraform-sqs?ref=4.0"

  environment-name       = var.environment-name
  team_name              = var.team_name
  infrastructure-support = var.infrastructure-support
  application            = var.application
  sqs_name               = "data_compliance_to_elite2_queue_dl"
  encrypt_sqs_kms        = "true"

  providers = {
    aws = aws.london
  }
}

resource "kubernetes_secret" "data_compliance_to_elite2_queue" {
  metadata {
    name      = "data-compliance-to-elite2-sqs"
    namespace = var.namespace
  }

  data = {
    access_key_id     = module.data_compliance_to_elite2_queue.access_key_id
    secret_access_key = module.data_compliance_to_elite2_queue.secret_access_key
    sqs_odg_url       = module.data_compliance_to_elite2_queue.sqs_id
    sqs_odg_arn       = module.data_compliance_to_elite2_queue.sqs_arn
    sqs_odg_name      = module.data_compliance_to_elite2_queue.sqs_name
  }
}

resource "kubernetes_secret" "data_compliance_to_elite2_dead_letter_queue" {
  metadata {
    name      = "data-compliance-to-elite2-sqs-dl"
    namespace = var.namespace
  }

  data = {
    access_key_id     = module.data_compliance_to_elite2_dead_letter_queue.access_key_id
    secret_access_key = module.data_compliance_to_elite2_dead_letter_queue.secret_access_key
    sqs_odg_url       = module.data_compliance_to_elite2_dead_letter_queue.sqs_id
    sqs_odg_arn       = module.data_compliance_to_elite2_dead_letter_queue.sqs_arn
    sqs_odg_name      = module.data_compliance_to_elite2_dead_letter_queue.sqs_name
  }
}
