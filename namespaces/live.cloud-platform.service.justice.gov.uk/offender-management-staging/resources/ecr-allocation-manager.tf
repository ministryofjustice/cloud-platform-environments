module "ecr-repo-allocation-manager" {
  source = "github.com/ministryofjustice/cloud-platform-terraform-ecr-credentials?ref=5.1.1"

  team_name = var.team_name
  repo_name = "offender-management-allocation-manager"

  providers = {
    aws = aws.london
  }
}

resource "kubernetes_secret" "ecr-repo-allocation-manager" {
  metadata {
    name      = "ecr-repo-allocation-manager"
    namespace = "offender-management-staging"
  }

  data = {
    repo_url          = module.ecr-repo-allocation-manager.repo_url
    access_key_id     = module.ecr-repo-allocation-manager.access_key_id
    secret_access_key = module.ecr-repo-allocation-manager.secret_access_key
  }
}

resource "kubernetes_secret" "ecr-repo-allocation-manager-test" {
  metadata {
    name      = "ecr-repo-allocation-manager"
    namespace = "offender-management-test"
  }

  data = {
    repo_url          = module.ecr-repo-allocation-manager.repo_url
    access_key_id     = module.ecr-repo-allocation-manager.access_key_id
    secret_access_key = module.ecr-repo-allocation-manager.secret_access_key
  }
}

resource "kubernetes_secret" "ecr-repo-allocation-manager-test2" {
  metadata {
    name      = "ecr-repo-allocation-manager"
    namespace = "offender-management-test2"
  }

  data = {
    repo_url          = module.ecr-repo-allocation-manager.repo_url
    access_key_id     = module.ecr-repo-allocation-manager.access_key_id
    secret_access_key = module.ecr-repo-allocation-manager.secret_access_key
  }
}

resource "kubernetes_secret" "ecr-repo-allocation-manager-preprod" {
  metadata {
    name      = "ecr-repo-allocation-manager"
    namespace = "offender-management-preprod"
  }

  data = {
    repo_url          = module.ecr-repo-allocation-manager.repo_url
    access_key_id     = module.ecr-repo-allocation-manager.access_key_id
    secret_access_key = module.ecr-repo-allocation-manager.secret_access_key
  }
}

resource "kubernetes_secret" "ecr-repo-allocation-manager-production" {
  metadata {
    name      = "ecr-repo-allocation-manager"
    namespace = "offender-management-production"
  }

  data = {
    repo_url          = module.ecr-repo-allocation-manager.repo_url
    access_key_id     = module.ecr-repo-allocation-manager.access_key_id
    secret_access_key = module.ecr-repo-allocation-manager.secret_access_key
  }
}
