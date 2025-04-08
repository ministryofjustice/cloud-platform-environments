module "test-ecr-repo" {
  source = "github.com/ministryofjustice/cloud-platform-terraform-ecr-credentials?ref=7.1.1"

  # Repository configuration
  repo_name = "${var.namespace}-ecr"

  # OpenID Connect configuration
  oidc_providers      = ["github"]
  github_repositories = ["sw-ecr-testing"]

  # Tags
  business_unit          = var.business_unit
  application            = var.application
  is_production          = var.is_production
  team_name              = var.team_name
  namespace              = var.namespace
  environment_name       = var.environment
  infrastructure_support = var.infrastructure_support
}

module "test_queue" {
  source = "github.com/ministryofjustice/cloud-platform-terraform-sqs?ref=5.1.1"

  # Queue configuration
  sqs_name                   = "test_queue"
  encrypt_sqs_kms            = "true"
  message_retention_seconds  = 345600
  visibility_timeout_seconds = 120

  # Tags
  business_unit          = var.business_unit
  application            = var.application
  is_production          = var.is_production
  team_name              = var.team_name # also used for naming the queue
  namespace              = var.namespace
  environment_name       = var.environment
  infrastructure_support = var.infrastructure_support
}

module "test_topic" {
  source = "github.com/ministryofjustice/cloud-platform-terraform-sns-topic?ref=5.1.1"

  # Configuration
  topic_display_name = "steve_test_topic"

  # Tags
  business_unit          = var.business_unit
  application            = var.application
  is_production          = var.is_production
  team_name              = var.team_name # also used for naming the topic
  namespace              = var.namespace
  environment_name       = var.environment
  infrastructure_support = var.infrastructure_support

  providers = {
    aws = aws.london
  }
}