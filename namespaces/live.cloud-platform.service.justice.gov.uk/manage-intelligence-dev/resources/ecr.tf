module "ecr-repo-extractor" {
  source = "github.com/ministryofjustice/cloud-platform-terraform-ecr-credentials?ref=5.3.0"

  team_name             = var.team_name
  repo_name             = "ims-legacy-data-extractor-${var.environment-name}"
  github_actions_prefix = "extractor${var.environment-name}"

  oidc_providers      = ["github"]
  github_repositories = ["hmpps-manage-intelligence-legacy-data-monorepo"]
}

resource "kubernetes_secret" "ims-legacy-data-extractor" {
  metadata {
    name      = "ims-legacy-data-extractor-ecr-output"
    namespace = var.namespace
  }

  data = {
    access_key_id     = module.ecr-repo-extractor.access_key_id
    secret_access_key = module.ecr-repo-extractor.secret_access_key
    repo_arn          = module.ecr-repo-extractor.repo_arn
    repo_url          = module.ecr-repo-extractor.repo_url
  }
}

module "ecr-repo-generator" {
  source = "github.com/ministryofjustice/cloud-platform-terraform-ecr-credentials?ref=5.3.0"

  team_name             = var.team_name
  repo_name             = "ims-legacy-test-generator-${var.environment-name}"
  github_actions_prefix = "generator-${var.environment-name}"

  oidc_providers      = ["github"]
  github_repositories = ["hmpps-manage-intelligence-legacy-data-monorepo"]
}

resource "kubernetes_secret" "ims-legacy-test-generator" {
  metadata {
    name      = "ims-legacy-test-generator-ecr-output"
    namespace = var.namespace
  }

  data = {
    access_key_id     = module.ecr-repo-generator.access_key_id
    secret_access_key = module.ecr-repo-generator.secret_access_key
    repo_arn          = module.ecr-repo-generator.repo_arn
    repo_url          = module.ecr-repo-generator.repo_url
  }
}

module "ecr-repo-transform" {
  source = "github.com/ministryofjustice/cloud-platform-terraform-ecr-credentials?ref=5.3.0"

  team_name             = var.team_name
  repo_name             = "ims-legacy-data-transform-${var.environment-name}"
  github_actions_prefix = "transform-${var.environment-name}"

  oidc_providers      = ["github"]
  github_repositories = ["hmpps-manage-intelligence-legacy-data-monorepo"]
}

resource "kubernetes_secret" "ims-legacy-data-transform" {
  metadata {
    name      = "ims-legacy-data-transform-ecr-output"
    namespace = var.namespace
  }

  data = {
    access_key_id     = module.ecr-repo-transform.access_key_id
    secret_access_key = module.ecr-repo-transform.secret_access_key
    repo_arn          = module.ecr-repo-transform.repo_arn
    repo_url          = module.ecr-repo-transform.repo_url
  }
}

module "ecr-repo-validator" {
  source = "github.com/ministryofjustice/cloud-platform-terraform-ecr-credentials?ref=5.3.0"

  team_name             = var.team_name
  repo_name             = "ims-legacy-temporary-clean-unmarshall-validator-${var.environment-name}"
  github_actions_prefix = "validator-${var.environment-name}"

  oidc_providers      = ["github"]
  github_repositories = ["hmpps-manage-intelligence-legacy-data-monorepo"]
}

resource "kubernetes_secret" "ims-legacy-temp-validator" {
  metadata {
    name      = "ims-legacy-temp-validator-ecr-output"
    namespace = var.namespace
  }

  data = {
    access_key_id     = module.ecr-repo-validator.access_key_id
    secret_access_key = module.ecr-repo-validator.secret_access_key
    repo_arn          = module.ecr-repo-validator.repo_arn
    repo_url          = module.ecr-repo-validator.repo_url
  }
}