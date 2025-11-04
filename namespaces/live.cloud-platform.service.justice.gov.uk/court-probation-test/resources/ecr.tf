module "court_probation_service_ecr_credentials" {
  source    = "github.com/ministryofjustice/cloud-platform-terraform-ecr-credentials?ref=8.0.0"
  repo_name = "court-probation-service"
  team_name = "probation-services"

  # Tags
  business_unit          = var.business_unit
  application            = var.application
  is_production          = var.is_production
  namespace              = var.namespace # also used for creating a Kubernetes ConfigMap
  environment_name       = var.environment
  infrastructure_support = var.infrastructure_support
  deletion_protection    = false

  providers = {
    aws = aws.london
  }
}

resource "kubernetes_secret" "court_probation_service_ecr_credentials" {
  metadata {
    name      = "court-probation-service-ecr-credentials"
    namespace = "court-probation-test"
  }

  data = {
    repo_arn = module.court_probation_service_ecr_credentials.repo_arn
    repo_url = module.court_probation_service_ecr_credentials.repo_url
  }
}

module "ps_cps_pack_parser_ecr_credentials" {
  source    = "github.com/ministryofjustice/cloud-platform-terraform-ecr-credentials?ref=8.0.0"
  repo_name = "cps-pack-parser"
  team_name = "probation-services"

  # Tags
  business_unit          = var.business_unit
  application            = var.application
  is_production          = var.is_production
  namespace              = var.namespace # also used for creating a Kubernetes ConfigMap
  environment_name       = var.environment
  infrastructure_support = var.infrastructure_support
  deletion_protection    = false

  providers = {
    aws = aws.london
  }
}

resource "kubernetes_secret" "ps_cps_pack_parser_ecr_credentials" {
  metadata {
    name      = "ps-cps-pack-parser-ecr-credentials"
    namespace = "court-probation-test"
  }

  data = {
    repo_arn = module.ps_cps_pack_parser_ecr_credentials.repo_arn
    repo_url = module.ps_cps_pack_parser_ecr_credentials.repo_url
  }
}

module "mock_cp_court_service_ecr_credentials" {
  source    = "github.com/ministryofjustice/cloud-platform-terraform-ecr-credentials?ref=8.0.0"
  repo_name = "mock-cp-court-service"
  team_name = "probation-services"

  # Tags
  business_unit          = var.business_unit
  application            = var.application
  is_production          = var.is_production
  namespace              = var.namespace # also used for creating a Kubernetes ConfigMap
  environment_name       = var.environment
  infrastructure_support = var.infrastructure_support
  deletion_protection    = false

  providers = {
    aws = aws.london
  }
}

resource "kubernetes_secret" "mock_cp_court_service_ecr_credentials" {
  metadata {
    name      = "mock-cp-court-service-ecr-credentials"
    namespace = "court-probation-test"
  }

  data = {
    repo_arn = module.mock_cp_court_service_ecr_credentials.repo_arn
    repo_url = module.mock_cp_court_service_ecr_credentials.repo_url
  }
}

module "court_list_service_ecr_credentials" {
  source    = "github.com/ministryofjustice/cloud-platform-terraform-ecr-credentials?ref=8.0.0"
  repo_name = "court-list-service"
  team_name = "probation-services"

  # Tags
  business_unit          = var.business_unit
  application            = var.application
  is_production          = var.is_production
  namespace              = var.namespace # also used for creating a Kubernetes ConfigMap
  environment_name       = var.environment
  infrastructure_support = var.infrastructure_support
  deletion_protection    = false

  providers = {
    aws = aws.london
  }
}

resource "kubernetes_secret" "court_list_service_ecr_credentials" {
  metadata {
    name      = "court-list-service-ecr-credentials"
    namespace = "court-probation-test"
  }

  data = {
    repo_arn = module.court_list_service_ecr_credentials.repo_arn
    repo_url = module.court_list_service_ecr_credentials.repo_url
  }
}

module "prepare_probation_courtcases_ecr_credentials" {
  source    = "github.com/ministryofjustice/cloud-platform-terraform-ecr-credentials?ref=8.0.0"
  repo_name = "prepare-probation-courtcases"
  team_name = "probation-services"

  # Tags
  business_unit          = var.business_unit
  application            = var.application
  is_production          = var.is_production
  namespace              = var.namespace # also used for creating a Kubernetes ConfigMap
  environment_name       = var.environment
  infrastructure_support = var.infrastructure_support
  deletion_protection    = false

  providers = {
    aws = aws.london
  }
}

resource "kubernetes_secret" "prepare_probation_courtcases_ecr_credentials" {
  metadata {
    name      = "prepare-probation-courtcases-ecr-credentials"
    namespace = "court-probation-test"
  }

  data = {
    repo_arn = module.prepare_probation_courtcases_ecr_credentials.repo_arn
    repo_url = module.prepare_probation_courtcases_ecr_credentials.repo_url
  }
}

module "ndelius_new_tech_ecr_credentials" {
  source    = "github.com/ministryofjustice/cloud-platform-terraform-ecr-credentials?ref=8.0.0"
  repo_name = "ndelius-new-tech"
  team_name = "probation-services"

  # Tags
  business_unit          = var.business_unit
  application            = var.application
  is_production          = var.is_production
  namespace              = var.namespace # also used for creating a Kubernetes ConfigMap
  environment_name       = var.environment
  infrastructure_support = var.infrastructure_support
  deletion_protection    = false

  providers = {
    aws = aws.london
  }
}

resource "kubernetes_secret" "ndelius_new_tech_ecr_credentials" {
  metadata {
    name      = "ndelius-new-tech-ecr-credentials"
    namespace = "court-probation-test"
  }

  data = {
    repo_arn = module.ndelius_new_tech_ecr_credentials.repo_arn
    repo_url = module.ndelius_new_tech_ecr_credentials.repo_url
  }
}

module "community_api_ecr_credentials" {
  source    = "github.com/ministryofjustice/cloud-platform-terraform-ecr-credentials?ref=8.0.0"
  repo_name = "community-api"
  team_name = "probation-services"

  # Tags
  business_unit          = var.business_unit
  application            = var.application
  is_production          = var.is_production
  namespace              = var.namespace # also used for creating a Kubernetes ConfigMap
  environment_name       = var.environment
  infrastructure_support = var.infrastructure_support
  deletion_protection    = false

  providers = {
    aws = aws.london
  }
}

resource "kubernetes_secret" "community_api_ecr_credentials" {
  metadata {
    name      = "community-api-ecr-credentials"
    namespace = "court-probation-test"
  }

  data = {
    repo_arn = module.community_api_ecr_credentials.repo_arn
    repo_url = module.community_api_ecr_credentials.repo_url
  }
}

module "ukcloud_proxy_ecr_credentials" {
  source    = "github.com/ministryofjustice/cloud-platform-terraform-ecr-credentials?ref=8.0.0"
  repo_name = "ukcloud-proxy"
  team_name = "probation-services"

  # Tags
  business_unit          = var.business_unit
  application            = var.application
  is_production          = var.is_production
  namespace              = var.namespace # also used for creating a Kubernetes ConfigMap
  environment_name       = var.environment
  infrastructure_support = var.infrastructure_support
  deletion_protection    = false

  providers = {
    aws = aws.london
  }
}

resource "kubernetes_secret" "ukcloud_proxy_ecr_credentials" {
  metadata {
    name      = "ukcloud-proxy-ecr-credentials"
    namespace = "court-probation-test"
  }

  data = {
    repo_arn = module.ukcloud_proxy_ecr_credentials.repo_arn
    repo_url = module.ukcloud_proxy_ecr_credentials.repo_url
  }
}

module "delius_oauth2_server_ecr_credentials" {
  source    = "github.com/ministryofjustice/cloud-platform-terraform-ecr-credentials?ref=8.0.0"
  repo_name = "delius-oauth2-server"
  team_name = "probation-services"

  # Tags
  business_unit          = var.business_unit
  application            = var.application
  is_production          = var.is_production
  namespace              = var.namespace # also used for creating a Kubernetes ConfigMap
  environment_name       = var.environment
  infrastructure_support = var.infrastructure_support
  deletion_protection    = false

  providers = {
    aws = aws.london
  }
}

resource "kubernetes_secret" "delius_oauth2_server_ecr_credentials" {
  metadata {
    name      = "delius-oauth2-server-ecr-credentials"
    namespace = var.namespace
  }

  data = {
    repo_arn = module.delius_oauth2_server_ecr_credentials.repo_arn
    repo_url = module.delius_oauth2_server_ecr_credentials.repo_url
  }
}

module "probation_court_prototype_ecr_credentials" {
  source    = "github.com/ministryofjustice/cloud-platform-terraform-ecr-credentials?ref=8.0.0"
  repo_name = "probation-court-prototype"
  team_name = "probation-services"

  # Tags
  business_unit          = var.business_unit
  application            = var.application
  is_production          = var.is_production
  namespace              = var.namespace # also used for creating a Kubernetes ConfigMap
  environment_name       = var.environment
  infrastructure_support = var.infrastructure_support
  deletion_protection    = false

  providers = {
    aws = aws.london
  }
}

resource "kubernetes_secret" "probation_court_prototype_ecr_credentials" {
  metadata {
    name      = "probation-court-prototype-ecr-credentials"
    namespace = var.namespace
  }

  data = {
    repo_arn = module.probation_court_prototype_ecr_credentials.repo_arn
    repo_url = module.probation_court_prototype_ecr_credentials.repo_url
  }
}

module "court_list_mock_data_ecr_credentials" {
  source    = "github.com/ministryofjustice/cloud-platform-terraform-ecr-credentials?ref=8.0.0"
  repo_name = "court-list-mock-data"
  team_name = "probation-services"

  # Tags
  business_unit          = var.business_unit
  application            = var.application
  is_production          = var.is_production
  namespace              = var.namespace # also used for creating a Kubernetes ConfigMap
  environment_name       = var.environment
  infrastructure_support = var.infrastructure_support
  deletion_protection    = false

  providers = {
    aws = aws.london
  }
}

resource "kubernetes_secret" "court_list_mock_data_ecr_credentials" {
  metadata {
    name      = "court-list-mock-data-ecr-credentials"
    namespace = "court-probation-test"
  }

  data = {
    repo_arn = module.court_list_mock_data_ecr_credentials.repo_arn
    repo_url = module.court_list_mock_data_ecr_credentials.repo_url
  }
}