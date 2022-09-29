# ECR for VCMS docker images
module "ecr_credentials_app" {
  source    = "github.com/ministryofjustice/cloud-platform-terraform-ecr-credentials?ref=4.8"
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
  source    = "github.com/ministryofjustice/cloud-platform-terraform-ecr-credentials?ref=4.8"
  team_name = var.team_name
  repo_name = "${var.namespace}-ecr-php-7-4-apache-buster"

  github_repositories = ["hmpps-vcms-app-cp"]
}

resource "kubernetes_secret" "ecr_credentials_php_7_4_apache_buster" {
  metadata {
    name      = "ecr-repo-php-7-4-apache-buster-${var.namespace}"
    namespace = var.namespace
  }

  data = {
    access_key_id     = module.ecr_credentials_php_7_4_apache_buster.access_key_id
    secret_access_key = module.ecr_credentials_php_7_4_apache_buster.secret_access_key
    repo_arn          = module.ecr_credentials_php_7_4_apache_buster.repo_arn
    repo_url          = module.ecr_credentials_php_7_4_apache_buster.repo_url
  }
}

# ECR for php:7.4-cli
module "ecr_credentials_php_7_4_cli" {
  source    = "github.com/ministryofjustice/cloud-platform-terraform-ecr-credentials?ref=4.8"
  team_name = var.team_name
  repo_name = "${var.namespace}-ecr-php-7-4-cli"

  github_repositories = ["hmpps-vcms-app-cp"]
}

resource "kubernetes_secret" "ecr_credentials_php_7_4_cli" {
  metadata {
    name      = "ecr-repo-php-7-4-cli-${var.namespace}"
    namespace = var.namespace
  }

  data = {
    access_key_id     = module.ecr_credentials_php_7_4_cli.access_key_id
    secret_access_key = module.ecr_credentials_php_7_4_cli.secret_access_key
    repo_arn          = module.ecr_credentials_php_7_4_cli.repo_arn
    repo_url          = module.ecr_credentials_php_7_4_cli.repo_url
  }
}

# ECR for mariadb:10.5.8
module "ecr_credentials_mariadb" {
  source    = "github.com/ministryofjustice/cloud-platform-terraform-ecr-credentials?ref=4.8"
  team_name = var.team_name
  repo_name = "${var.namespace}-ecr-mariadb"

  github_repositories = ["hmpps-vcms-app-cp"]
}

resource "kubernetes_secret" "ecr_credentials_mariadb" {
  metadata {
    name      = "ecr-repo-mariadb-${var.namespace}"
    namespace = var.namespace
  }

  data = {
    access_key_id     = module.ecr_credentials_mariadb.access_key_id
    secret_access_key = module.ecr_credentials_mariadb.secret_access_key
    repo_arn          = module.ecr_credentials_mariadb.repo_arn
    repo_url          = module.ecr_credentials_mariadb.repo_url
  }
}

# ECR for redis:5.0.6
module "ecr_credentials_redis" {
  source    = "github.com/ministryofjustice/cloud-platform-terraform-ecr-credentials?ref=4.8"
  team_name = var.team_name
  repo_name = "${var.namespace}-ecr-redis"

  github_repositories = ["hmpps-vcms-app-cp"]
}

resource "kubernetes_secret" "ecr_credentials_redis" {
  metadata {
    name      = "ecr-repo-redis-${var.namespace}"
    namespace = var.namespace
  }

  data = {
    access_key_id     = module.ecr_credentials_redis.access_key_id
    secret_access_key = module.ecr_credentials_redis.secret_access_key
    repo_arn          = module.ecr_credentials_redis.repo_arn
    repo_url          = module.ecr_credentials_redis.repo_url
  }
}

# ECR for phpmyadmin/phpmyadmin
module "ecr_credentials_phpmyadmin" {
  source    = "github.com/ministryofjustice/cloud-platform-terraform-ecr-credentials?ref=4.8"
  team_name = var.team_name
  repo_name = "${var.namespace}-ecr-phpmyadmin"

  # github actions CI/CD pipelines
  github_repositories = ["hmpps-vcms-app-cp"]
}

resource "kubernetes_secret" "ecr_credentials_phpmyadmin" {
  metadata {
    name      = "ecr-repo-phpmyadmin-${var.namespace}"
    namespace = var.namespace
  }

  data = {
    access_key_id     = module.ecr_credentials_phpmyadmin.access_key_id
    secret_access_key = module.ecr_credentials_phpmyadmin.secret_access_key
    repo_arn          = module.ecr_credentials_phpmyadmin.repo_arn
    repo_url          = module.ecr_credentials_phpmyadmin.repo_url
  }
}

# ECR for node:14.15.4-buster
module "ecr_credentials_node_14_15_4_buster" {
  source    = "github.com/ministryofjustice/cloud-platform-terraform-ecr-credentials?ref=4.8"
  team_name = var.team_name
  repo_name = "${var.namespace}-ecr-node-14-15-4-buster"

  github_repositories = ["hmpps-vcms-app-cp"]
}

resource "kubernetes_secret" "ecr_credentials_node_14_15_4_buster" {
  metadata {
    name      = "ecr-repo-node-14-15-4-buster-${var.namespace}"
    namespace = var.namespace
  }

  data = {
    access_key_id     = module.ecr_credentials_node_14_15_4_buster.access_key_id
    secret_access_key = module.ecr_credentials_node_14_15_4_buster.secret_access_key
    repo_arn          = module.ecr_credentials_node_14_15_4_buster.repo_arn
    repo_url          = module.ecr_credentials_node_14_15_4_buster.repo_url
  }
}