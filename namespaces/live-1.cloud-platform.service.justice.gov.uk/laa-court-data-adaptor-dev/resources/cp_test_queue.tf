module "cp_test_queue" {
  source = "github.com/ministryofjustice/cloud-platform-terraform-sqs?ref=4.0"

  environment-name       = "development"
  team_name              = "crimeapps"
  infrastructure-support = "praveen.raju@digtal.justice.gov.uk"
  application            = "crimeapps"
  sqs_name               = "cp-test-queue"

  encrypt_sqs_kms = "false"


  providers = {
    aws = aws.london
  }
}

resource "kubernetes_secret" "cp_test_queue" {
  metadata {
    name      = "cp-test-instance-output"
    namespace = "laa-court-adaptor-dev"
  }

  data = {
    access_key_id     = module.cp_test_queue.access_key_id
    secret_access_key = module.cp_test_queue.secret_access_key
    sqs_id            = module.cp_test_queue.sqs_id
    sqs_arn           = module.cp_test_queue.sqs_arn
    sqs_name          = module.cp_test_queue.sqs_name
  }
}