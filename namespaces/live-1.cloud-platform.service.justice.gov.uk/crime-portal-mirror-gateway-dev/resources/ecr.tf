
// This registry is used in the dev, preprod and prod namespaces which all deploy the same image from this ECR

module "pict_cpmg_database_ecr_credentials" {
  source    = "github.com/ministryofjustice/cloud-platform-terraform-ecr-credentials?ref=4.3"
  repo_name = "cpmg-database"
  team_name = "probation-in-court"

  providers = {
    aws = aws.london
  }
}

module "pict_cpmg_wildfly_ecr_credentials" {
  source    = "github.com/ministryofjustice/cloud-platform-terraform-ecr-credentials?ref=4.3"
  repo_name = "cpmg-wildfly"
  team_name = "probation-in-court"

  providers = {
    aws = aws.london
  }
}

resource "kubernetes_secret" "pict_cpmg_database_ecr_credentials" {
  metadata {
    name      = "pict-cpmg-ecr-database-credentials-output"
    namespace = "crime-portal-mirror-gateway-dev"
  }

  data = {
    access_key_id     = module.pict_cpmg_database_ecr_credentials.access_key_id
    secret_access_key = module.pict_cpmg_database_ecr_credentials.secret_access_key
    repo_arn          = module.pict_cpmg_database_ecr_credentials.repo_arn
    repo_url          = module.pict_cpmg_database_ecr_credentials.repo_url
  }
}

resource "kubernetes_secret" "pict_cpmg_wildfly_ecr_credentials" {
  metadata {
    name      = "pict-cpmg-ecr-wildfly-credentials-output"
    namespace = "crime-portal-mirror-gateway-dev"
  }

  data = {
    access_key_id     = module.pict_cpmg_wildfly_ecr_credentials.access_key_id
    secret_access_key = module.pict_cpmg_wildfly_ecr_credentials.secret_access_key
    repo_arn          = module.pict_cpmg_wildfly_ecr_credentials.repo_arn
    repo_url          = module.pict_cpmg_wildfly_ecr_credentials.repo_url
  }
}

resource "kubernetes_secret" "pict_cpmg_database_ecr_credentials_preprod" {
  metadata {
    name      = "pict-cpmg-ecr-database-credentials-output"
    namespace = "crime-portal-mirror-gateway-preprod"
  }

  data = {
    access_key_id     = module.pict_cpmg_database_ecr_credentials.access_key_id
    secret_access_key = module.pict_cpmg_database_ecr_credentials.secret_access_key
    repo_arn          = module.pict_cpmg_database_ecr_credentials.repo_arn
    repo_url          = module.pict_cpmg_database_ecr_credentials.repo_url
  }
}

resource "kubernetes_secret" "pict_cpmg_wildfly_ecr_credentials_preprod" {
  metadata {
    name      = "pict-cpmg-ecr-wildfly-credentials-output"
    namespace = "crime-portal-mirror-gateway-preprod"
  }

  data = {
    access_key_id     = module.pict_cpmg_wildfly_ecr_credentials.access_key_id
    secret_access_key = module.pict_cpmg_wildfly_ecr_credentials.secret_access_key
    repo_arn          = module.pict_cpmg_wildfly_ecr_credentials.repo_arn
    repo_url          = module.pict_cpmg_wildfly_ecr_credentials.repo_url
  }
}

resource "kubernetes_secret" "pict_cpmg_database_ecr_credentials_prod" {
  metadata {
    name      = "pict-cpmg-ecr-database-credentials-output"
    namespace = "crime-portal-mirror-gateway-prod"
  }

  data = {
    access_key_id     = module.pict_cpmg_database_ecr_credentials.access_key_id
    secret_access_key = module.pict_cpmg_database_ecr_credentials.secret_access_key
    repo_arn          = module.pict_cpmg_database_ecr_credentials.repo_arn
    repo_url          = module.pict_cpmg_database_ecr_credentials.repo_url
  }
}

resource "kubernetes_secret" "pict_cpmg_wildfly_ecr_credentials_prod" {
  metadata {
    name      = "pict-cpmg-ecr-wildfly-credentials-output"
    namespace = "crime-portal-mirror-gateway-prod"
  }

  data = {
    access_key_id     = module.pict_cpmg_wildfly_ecr_credentials.access_key_id
    secret_access_key = module.pict_cpmg_wildfly_ecr_credentials.secret_access_key
    repo_arn          = module.pict_cpmg_wildfly_ecr_credentials.repo_arn
    repo_url          = module.pict_cpmg_wildfly_ecr_credentials.repo_url
  }
}
