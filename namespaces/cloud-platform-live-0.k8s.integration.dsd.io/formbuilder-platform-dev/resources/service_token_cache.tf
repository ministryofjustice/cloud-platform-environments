########################################################
# Service Token Cache Elasticache Redis (for resque + job logging)
module "service-token-cache-elasticache" {
  source = "github.com/ministryofjustice/cloud-platform-terraform-elasticache-cluster?ref=2.0"

  cluster_name         = "${var.cluster_name}"
  cluster_state_bucket = "${var.cluster_state_bucket}"

  application            = "formbuilderservice-token-cache"
  environment-name       = "${var.environment-name}"
  is-production          = "${var.is-production}"
  infrastructure-support = "${var.infrastructure-support}"
  team_name              = "${var.team_name}"
}

resource "kubernetes_secret" "service-token-cache-elasticache" {
  metadata {
    name      = "elasticache-formbuilder-service-token-cache-dev"
    namespace = "formbuilder-platform-dev"
  }

  data {
    primary_endpoint_address = "${module.service-token-cache-elasticache.primary_endpoint_address}"
    auth_token               = "${module.service-token-cache-elasticache.auth_token}"
  }
}

########################################################

# Service Token Cache ECR Repos
module "ecr-repo-fb-service-token-cache" {
  source = "github.com/ministryofjustice/cloud-platform-terraform-ecr-credentials?ref=1.0"

  team_name = "${var.team_name}"
  repo_name = "fb-service-token-cache"
}

resource "kubernetes_secret" "ecr-repo" {
  metadata {
    name      = "ecr-repo-fb-service-token-cache"
    namespace = "formbuilder-platform-dev"
  }

  data {
    repo_url          = "${module.ecr-repo-fb-service-token-cache.repo_url}"
    access_key_id     = "${module.ecr-repo-fb-service-token-cache.access_key_id}"
    secret_access_key = "${module.ecr-repo-fb-service-token-cache.secret_access_key}"
  }
}
