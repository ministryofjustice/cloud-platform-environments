module "abundant_namespace_sqs" {
  # remember to check the latest version
  source = "github.com/ministryofjustice/cloud-platform-terraform-sqs?ref=4.10.1"

  sqs_name = "abundant_namespace_sqs"
  # if true, the sqs_name above must end with ".fifo", it's an API quirk
  fifo_queue             = false
  team_name              = var.team_name
  business-unit          = var.business_unit
  application            = var.application
  is-production          = var.is_production
  environment-name       = "dev"
  infrastructure-support = var.infrastructure_support
  namespace              = var.namespace

  # Set encrypt_sqs_kms = "true", to enable SSE for SQS using KMS key.
  encrypt_sqs_kms = "false"

  # existing_user_name     = module.another_sqs_instance.user_name

  providers = {
    aws = aws.london
  }
}

resource "kubernetes_secret" "abundant_namespace_sqs" {
  metadata {
    name      = "sqs"
    namespace = var.namespace
  }

  data = {
    access_key_id     = module.abundant_namespace_sqs.access_key_id
    secret_access_key = module.abundant_namespace_sqs.secret_access_key
    # the above will not be set if existing_user_name is defined
    sqs_id   = module.abundant_namespace_sqs.sqs_id
    sqs_arn  = module.abundant_namespace_sqs.sqs_arn
    sqs_name = module.abundant_namespace_sqs.sqs_name
  }
}

