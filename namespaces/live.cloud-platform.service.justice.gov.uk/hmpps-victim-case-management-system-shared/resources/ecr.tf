# ECR for VCMS docker images
module "ecr_credentials_app" {
  source    = "github.com/ministryofjustice/cloud-platform-terraform-ecr-credentials?ref=5.1.1"
  team_name = var.team_name
  repo_name = "${var.namespace}-ecr-app"

  github_repositories = ["hmpps-vcms-app-cp"]
}

resource "kubernetes_secret" "ecr_credentials_app" {
  metadata {
    name      = "ecr-repo-app-${var.namespace}"
    namespace = var.namespace
  }

  data = {
    access_key_id     = module.ecr_credentials_app.access_key_id
    secret_access_key = module.ecr_credentials_app.secret_access_key
    repo_arn          = module.ecr_credentials_app.repo_arn
    repo_url          = module.ecr_credentials_app.repo_url
  }
}

# ECR for php:7.4-apache-buster
module "ecr_credentials_php_7_4_apache_buster" {
  source    = "github.com/ministryofjustice/cloud-platform-terraform-ecr-credentials?ref=5.1.1"
  team_name = var.team_name
  repo_name = "${var.namespace}-ecr-php-7-4-apache-buster"
}

# ECR for php:7.4-cli
module "ecr_credentials_php_7_4_cli" {
  source    = "github.com/ministryofjustice/cloud-platform-terraform-ecr-credentials?ref=5.1.1"
  team_name = var.team_name
  repo_name = "${var.namespace}-ecr-php-7-4-cli"
}

# ECR for mariadb:10.5.8
module "ecr_credentials_mariadb" {
  source    = "github.com/ministryofjustice/cloud-platform-terraform-ecr-credentials?ref=5.1.1"
  team_name = var.team_name
  repo_name = "${var.namespace}-ecr-mariadb"
}

# ECR for redis:5.0.6
module "ecr_credentials_redis" {
  source    = "github.com/ministryofjustice/cloud-platform-terraform-ecr-credentials?ref=5.1.1"
  team_name = var.team_name
  repo_name = "${var.namespace}-ecr-redis"
}

# ECR for phpmyadmin/phpmyadmin
module "ecr_credentials_phpmyadmin" {
  source    = "github.com/ministryofjustice/cloud-platform-terraform-ecr-credentials?ref=5.1.1"
  team_name = var.team_name
  repo_name = "${var.namespace}-ecr-phpmyadmin"
}

# ECR for node:14.15.4-buster
module "ecr_credentials_node_14_15_4_buster" {
  source    = "github.com/ministryofjustice/cloud-platform-terraform-ecr-credentials?ref=5.1.1"
  team_name = var.team_name
  repo_name = "${var.namespace}-ecr-node-14-15-4-buster"
}

# ECR for nfs
module "ecr_credentials_nfs" {
  source    = "github.com/ministryofjustice/cloud-platform-terraform-ecr-credentials?ref=5.1.1"
  team_name = var.team_name
  repo_name = "${var.namespace}-ecr-nfs"
}

# ECR for testing-robot
module "ecr_credentials_testing_robot" {
  source    = "github.com/ministryofjustice/cloud-platform-terraform-ecr-credentials?ref=5.1.1"
  team_name = var.team_name
  repo_name = "${var.namespace}-ecr-testing-robot"
}

# ECR for artisan
module "ecr_credentials_artisan" {
  source    = "github.com/ministryofjustice/cloud-platform-terraform-ecr-credentials?ref=5.1.1"
  team_name = var.team_name
  repo_name = "${var.namespace}-ecr-artisan"
}
