# module "sqs" {
#   source = "github.com/ministryofjustice/cloud-platform-terraform-sqs?ref=5.1.2" # use the latest release

#   # Queue configuration
#   sqs_name        = "tim-testing"
#   encrypt_sqs_kms = "true"

#   # Tags
#   business_unit          = var.business_unit
#   application            = var.application
#   is_production          = var.is_production
#   team_name              = var.team_name # also used for naming the queue
#   namespace              = var.namespace
#   environment_name       = var.environment
#   infrastructure_support = var.infrastructure_support
# }