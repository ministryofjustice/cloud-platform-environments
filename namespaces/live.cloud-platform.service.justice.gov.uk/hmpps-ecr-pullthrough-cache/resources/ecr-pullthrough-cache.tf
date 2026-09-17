# ECR pull-through cache for ghcr.io. Pull via <account_id>.dkr.ecr.eu-west-2.amazonaws.com/ghcr/<org>/<image>:<tag>;
# ECR fetches uncached images from ghcr.io on first pull and serves cached ones after (refreshed ~daily).
#
# The secret below is created with a placeholder, after applying, set the real value in Secrets Manager:
# {"username": "...", "accessToken": "<PAT, read:packages>"}
# See `lifecycle.ignore_changes` which stops Terraform reverting it back to the placeholder.

resource "aws_secretsmanager_secret" "ghcr_pullthroughcache" {
  # Name MUST use the "ecr-pullthroughcache/" prefix - this is an AWS requirement.
  name        = "ecr-pullthroughcache/ghcr-credentials"
  description = "Upstream credentials for the ECR pull-through cache rule proxying ghcr.io"
}

resource "aws_secretsmanager_secret_version" "ghcr_pullthroughcache" {
  secret_id = aws_secretsmanager_secret.ghcr_pullthroughcache.id
  secret_string = jsonencode({
    username    = "REPLACE_ME"
    accessToken = "REPLACE_ME"
  })

  lifecycle {
    ignore_changes = [secret_string]
  }
}

resource "aws_ecr_pull_through_cache_rule" "ghcr" {
  ecr_repository_prefix = "ghcr"
  upstream_registry_url = "ghcr.io"
  credential_arn        = aws_secretsmanager_secret.ghcr_pullthroughcache.arn
}

resource "aws_ecr_repository_creation_template" "ghcr" {
  prefix      = "ghcr"
  description = "Applies to repos auto-created by the ghcr.io pull-through cache rule"
  applied_for = ["PULL_THROUGH_CACHE"]

  lifecycle_policy = jsonencode({
    rules = [
      {
        rulePriority = 1
        description  = "Expire images older than 60 days"
        selection = {
          tagStatus   = "any"
          countType   = "sinceImagePushed"
          countUnit   = "days"
          countNumber = 60
        }
        action = {
          type = "expire"
        }
      }
    ]
  })
}

data "aws_caller_identity" "current" {}

output "ecr_registry" {
  value = "${data.aws_caller_identity.current.account_id}.dkr.ecr.eu-west-2.amazonaws.com"
}
