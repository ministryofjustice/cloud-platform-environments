module "test_sqs_creation" {
  source = "github.com/ministryofjustice/cloud-platform-terraform-sqs?ref=4.2"

  environment-name       = var.environment
  team_name              = var.team_name
  infrastructure-support = var.infrastructure_support
  application            = var.application
  sqs_name               = "test_sqs_creation"
  namespace              = var.namespace

  # Set encrypt_sqs_kms = "true", to enable SSE for SQS using KMS key.
  encrypt_sqs_kms = "false"

  # existing_user_name     = module.another_sqs_instance.user_name

  providers = {
    aws = aws.london
  }
}

resource "kubernetes_secret" "example_sqs" {
  metadata {
    name      = "test-sqs-creation""
    namespace = var.namespace
  }

  data = {
    access_key_id     = module.test_sqs_creation.access_key_id
    secret_access_key = module.test_sqs_creation.secret_access_key
    # the above will not be set if existing_user_name is defined
    sqs_id   = module.test_sqs_creation.sqs_id
    sqs_arn  = module.test_sqs_creation.sqs_arn
    sqs_name = module.test_sqs_creation.sqs_name
  }
}
