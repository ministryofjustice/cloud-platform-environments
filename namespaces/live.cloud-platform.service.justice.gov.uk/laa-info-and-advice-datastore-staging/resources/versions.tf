terraform {
  required_version = ">= 1.2.5"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.78.0"
    }
    github = {
      source  = "integrations/github"
      version = "~> 6.6.0"
    }
    kubernetes = {
      source  = "hashicorp/kubernetes"
      version = "~> 2.23.0"
    }
    # Kept temporarily to allow destroy of postgresql_grant_role.rds_iam
    # as part of the IRSA revert (MEM-1138). Remove in a follow-up PR.
    postgresql = {
      source  = "cyrilgdn/postgresql"
      version = "~> 1.26.0"
    }
  }
}
