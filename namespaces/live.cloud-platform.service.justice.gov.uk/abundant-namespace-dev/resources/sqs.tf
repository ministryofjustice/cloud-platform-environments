module "abundant_namespace_sqs" {
  source = "github.com/ministryofjustice/cloud-platform-terraform-sqs?ref=4.12.0"

  # Queue configuration
  sqs_name        = "abundant_namespace_sqs"
  encrypt_sqs_kms = "false"

  # Tags
  business_unit          = var.business_unit
  application            = var.application
  is_production          = var.is_production
  team_name              = var.team_name # also used for naming the queue
  namespace              = var.namespace
  environment_name       = var.environment
  infrastructure_support = var.infrastructure_support

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
