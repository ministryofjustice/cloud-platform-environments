module "elite2_to_data_compliance_queue" {
  source = "github.com/ministryofjustice/cloud-platform-terraform-sqs?ref=4.0"

  environment-name           = var.environment-name
  team_name                  = var.team_name
  infrastructure-support     = var.infrastructure-support
  application                = var.application
  sqs_name                   = "elite2_to_data_compliance_queue"
  encrypt_sqs_kms            = "true"
  visibility_timeout_seconds = 300
  message_retention_seconds  = 1209600

  redrive_policy = <<EOF
  {
    "deadLetterTargetArn": "${module.elite2_to_data_compliance_dead_letter_queue.sqs_arn}","maxReceiveCount": 3
  }
  EOF

  providers = {
    aws = aws.london
  }
}

module "elite2_to_data_compliance_dead_letter_queue" {
  source = "github.com/ministryofjustice/cloud-platform-terraform-sqs?ref=4.0"

  environment-name       = var.environment-name
  team_name              = var.team_name
  infrastructure-support = var.infrastructure-support
  application            = var.application
  sqs_name               = "elite2_to_data_compliance_queue_dl"
  encrypt_sqs_kms        = "true"

  providers = {
    aws = aws.london
  }
}

resource "kubernetes_secret" "elite2_to_data_compliance_queue" {
  metadata {
    name      = "elite2-to-data-compliance-sqs"
    namespace = var.namespace
  }

  data = {
    access_key_id     = module.elite2_to_data_compliance_queue.access_key_id
    secret_access_key = module.elite2_to_data_compliance_queue.secret_access_key
    sqs_opd_url       = module.elite2_to_data_compliance_queue.sqs_id
    sqs_opd_arn       = module.elite2_to_data_compliance_queue.sqs_arn
    sqs_opd_name      = module.elite2_to_data_compliance_queue.sqs_name
  }
}

resource "kubernetes_secret" "elite2_to_data_compliance_dead_letter_queue" {
  metadata {
    name      = "elite2-to-data-compliance-sqs-dl"
    namespace = var.namespace
  }

  data = {
    access_key_id     = module.elite2_to_data_compliance_dead_letter_queue.access_key_id
    secret_access_key = module.elite2_to_data_compliance_dead_letter_queue.secret_access_key
    sqs_opd_url       = module.elite2_to_data_compliance_dead_letter_queue.sqs_id
    sqs_opd_arn       = module.elite2_to_data_compliance_dead_letter_queue.sqs_arn
    sqs_opd_name      = module.elite2_to_data_compliance_dead_letter_queue.sqs_name
  }
}
