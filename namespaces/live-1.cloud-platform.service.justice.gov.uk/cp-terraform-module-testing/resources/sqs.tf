module "example_sqs" {
  source = "github.com/ministryofjustice/cloud-platform-terraform-sqs?ref=4.0"

  environment-name       = "test"
  team_name              = "cp"
  infrastructure-support = "example-team@digtal.justice.gov.uk"
  application            = "cptf11app"
  sqs_name               = "cptf11sqsname"

  # Set encrypt_sqs_kms = "true", to enable SSE for SQS using KMS key.
  encrypt_sqs_kms = "false"

  # existing_user_name     = "${module.another_sqs_instance.user_name}"

  providers = {
    aws = aws.london
  }
}

resource "kubernetes_secret" "example_sqs" {
  metadata {
    name      = "cp-sqs"
    namespace = "cp-terraform-module-testing"
  }

  data = {
    access_key_id     = module.example_sqs.access_key_id
    secret_access_key = module.example_sqs.secret_access_key
    # the above will not be set if existing_user_name is defined
    sqs_id   = module.example_sqs.sqs_id
    sqs_arn  = module.example_sqs.sqs_arn
    sqs_name = module.example_sqs.sqs_name
  }
}

