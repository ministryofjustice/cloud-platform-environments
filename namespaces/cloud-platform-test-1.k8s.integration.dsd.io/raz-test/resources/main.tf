terraform {
  backend "s3" {}
}

provider "aws" {
  region  = "eu-west-1"
  version = "~> 1.17.0"
}

module "rds-instance" {
  source = "github.com/ministryofjustice/cloud-platform-terraform-rds-instance?ref=master"

  team_name                   = "raz-test"
  db_backup_retention_period  = "1"
  application                 = "raz-test"
  environment-name            = "dev"
  is-production               = "false"
  infrastructure-support      = "Raz razvan.cosma@digital.justice.gov.uk"
}

resource "kubernetes_secret" "rds-instance" {
  metadata {
    name      = "rds-instance"
    namespace = "raz-test"
  }

  data {
    instance_id         = "${module.rds-instance.rds_instance_id}"
    arn                 = "${module.rds-instance.rds_instance_arn}"
    url                 = "postgres://${module.rds-instance.database_username}:${module.rds-instance.database_password}@${module.rds-instance.rds_instance_endpoint}/${module.rds-instance.database_name}"
    kms_key_id          = "${module.rds-instance.kms_key_id}"
    access_key_id       = "${module.rds-instance.access_key_id}"
    secret_access_key   = "${module.rds-instance.secret_access_key}"
  }
}

module "ecr-repo" {
  source = "github.com/ministryofjustice/cloud-platform-terraform-ecr-credentials?ref=master"

  team_name = "raz-test"
  repo_name = "raz-test"
}

resource "kubernetes_secret" "ecr-repo" {
  metadata {
    name      = "ecr-instance"
    namespace = "raz-test"
  }

  data {
    repo_url          = "${module.ecr-repo.repo_url}"
    access_key_id     = "${module.ecr-repo.access_key_id}"
    secret_access_key = "${module.ecr-repo.secret_access_key}"
  }
}

module "dynamodb" {
  source = "github.com/ministryofjustice/cloud-platform-terraform-dynamodb-cluster?ref=create-db"

  team_name              = "raz-test"
  business-unit          = "example-bu"
  application            = "exampleapp"
  is-production          = "false"
  environment-name       = "development"
  infrastructure-support = "razvan.cosma@digtal.justice.gov.uk"

  hash_key  = "example-hash"
  range_key = "example-range"
}

resource "kubernetes_secret" "dynamodb" {
  metadata {
    name      = "dynamodb"
    namespace = "raz-test"
  }

  data {
    name = "${module.dynamodb.table_name}"
    access_key_id     = "${module.dynamodb.access_key_id}"
    secret_access_key = "${module.dynamodb.secret_access_key}"
  }
}

module "elasticache" {
  source = "github.com/ministryofjustice/cloud-platform-terraform-elasticache-cluster?ref=add/ec-terra"

  team_name              = "raz-test"
  ec_engine              = "redis"
  engine_version         = "4.0.10"
  parameter_group_name   = "default.redis4.0"
  node_type              = "cache.m3.medium"
  number_of_nodes        = 1
  port                   = 6379
  ec_subnet_groups       = ["subnet-7293103a", "subnet-7bf10c21", "subnet-de00b3b8"]
  business-unit          = "raz-test"
  application            = "raz-test"
  is-production          = "false"
  environment-name       = "development"
  infrastructure-support = "razvan.cosma@digtal.justice.gov.uk"
}

resource "kubernetes_secret" "elasticache" {
  metadata {
    name      = "elasticache"
    namespace = "raz-test"
  }

  data {
    name = "${module.elasticache.cache_nodes}"
  }
}
