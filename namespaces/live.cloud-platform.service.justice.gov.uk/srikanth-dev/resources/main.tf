terraform {
  backend "s3" {
  }
}

provider "aws" {
  region = "eu-west-2"

  default_tags {
    tags = {
      source-code   = "github.com/ministryofjustice/cloud-platform-environments"
      slack-channel = var.slack_channel
    }
  }
}

provider "aws" {
  alias  = "london"
  region = "eu-west-2"

  default_tags {
    tags = {
      source-code   = "github.com/ministryofjustice/cloud-platform-environments"
      slack-channel = var.slack_channel
    }
  }
}

provider "aws" {
  alias  = "ireland"
  region = "eu-west-1"

  default_tags {
    tags = {
      source-code   = "github.com/ministryofjustice/cloud-platform-environments"
      slack-channel = var.slack_channel
    }
  }
}

provider "github" {
  token = var.github_token
  owner = var.github_owner
}

provider "kubernetes" {}

module "irsa" {
  source = "github.com/ministryofjustice/cloud-platform-terraform-irsa?ref=2.0.0"

  # EKS configuration
  eks_cluster_name = var.eks_cluster_name

  # IRSA configuration
  service_account_name = "srikanth-service-account"
  namespace            = var.namespace # this is also used as a tag

  # Attach the appropriate policies using a key => value map
  # If you're using Cloud Platform provided modules (e.g. SNS, S3), these
  # provide an output called `irsa_policy_arn` that can be used.
  role_policy_arns = {
    ...
    s3  = module.s3.irsa_policy_arn
    dms = module.dms.irsa_policy_arn
    sqs = module.sqs.irsa_policy_arn
    ...
  }

  # Tags
  business_unit          = var.business_unit
  application            = var.application
  is_production          = var.is_production
  team_name              = var.team_name
  environment_name       = var.environment
  infrastructure_support = var.infrastructure_support
}
