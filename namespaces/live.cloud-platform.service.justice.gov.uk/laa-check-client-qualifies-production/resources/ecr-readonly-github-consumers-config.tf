#############################################
# ECR read-only consumer configuration
#############################################

locals {
  ecr_readonly_name_prefix         = "ccq-ecr-readonly"
  ecr_readonly_github_organisation = var.github_owner

  ecr_readonly_tags = {
    component = "ecr-readonly-consumer-access"
  }

  ecr_readonly_consumers = {
    rcw = {
      repository = "laa-record-controlled-work"

      # GitHub Actions OIDC subject suffixes.
      # https://docs.github.com/en/actions/reference/security/oidc#example-subject-claims
      subjects = [
        "ref:refs/heads/main",
        "pull_request"
      ]

      # Prefix used for GitHub Actions secrets/variables in the consumer repo.
      #
      # Secrets:
      # - secrets.CCQ_ECR_READONLY_ROLE_TO_ASSUME
      # - secrets.CCQ_ECR_REGISTRY_URL
      #
      # Variables:
      # - vars.CCQ_ECR_REGION
      # - vars.CCQ_ECR_REPOSITORY
      prefix = "CCQ"
    }
  }
}