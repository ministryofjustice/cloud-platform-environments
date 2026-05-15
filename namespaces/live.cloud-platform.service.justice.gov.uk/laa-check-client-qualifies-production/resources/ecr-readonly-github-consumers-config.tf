#############################################
# ECR read-only consumer configuration
#############################################

locals {
  ecr_readonly_name_prefix         = "ccq-ecr-readonly"
  ecr_readonly_github_organisation = "ministryofjustice"

  ecr_readonly_tags = {
    component = "ecr-readonly-consumer-access"
  }

  ecr_readonly_consumers = {
    rcw = {
      repository = "laa-record-controlled-work"

      # GitHub Actions OIDC subject suffixes.
      #
      # - ref:refs/heads/main
      # - environment:e2e
      # - pull_request
      subjects = [
        "ref:refs/heads/main"
      ]

      # Prefix used for GitHub Actions secrets/variables in the consumer repo.
      #
      # - secrets.CCQ_ECR_READONLY_ROLE_TO_ASSUME
      # - vars.CCQ_ECR_REGION
      # - vars.CCQ_ECR_REGISTRY_URL
      # - vars.CCQ_ECR_REPOSITORY
      # - vars.CCQ_ECR_REPOSITORY_URL
      prefix = "CCQ"
    }
  }
}