# Publisher ECR Repos

module "ecr-repo-fb-publisher-base" {
  source = "github.com/ministryofjustice/cloud-platform-terraform-ecr-credentials?ref=7.0.0"

  team_name = "formbuilder"
  repo_name = "fb-publisher-base"

  lifecycle_policy = var.lifecycle_policy

  oidc_providers      = ["circleci"]
  github_repositories = ["fb-publisher"]
  namespace           = var.namespace

  # Tags
  business_unit          = "Platforms"
  application            = "Form Builder"
  is_production          = "true"
  environment_name       = "production"
  infrastructure_support = "form-builder-developers@digital.justice.gov.uk"

  providers = {
    aws = aws.london
  }
}

resource "kubernetes_secret" "ecr-repo-fb-publisher-base" {
  metadata {
    name      = "ecr-repo-fb-publisher-base"
    namespace = "formbuilder-repos"
  }

  data = {
    repo_url = module.ecr-repo-fb-publisher-base.repo_url
  }
}

module "ecr-repo-fb-publisher-web" {
  source = "github.com/ministryofjustice/cloud-platform-terraform-ecr-credentials?ref=7.0.0"

  team_name = "formbuilder"
  repo_name = "fb-publisher-web"

  lifecycle_policy = var.lifecycle_policy

  oidc_providers      = ["circleci"]
  github_repositories = ["fb-publisher"]
  namespace           = var.namespace

  # Tags
  business_unit          = "Platforms"
  application            = "Form Builder"
  is_production          = "true"
  environment_name       = "production"
  infrastructure_support = "form-builder-developers@digital.justice.gov.uk"

  providers = {
    aws = aws.london
  }
}

resource "kubernetes_secret" "ecr-repo-fb-publisher-web" {
  metadata {
    name      = "ecr-repo-fb-publisher-web"
    namespace = "formbuilder-repos"
  }

  data = {
    repo_url = module.ecr-repo-fb-publisher-web.repo_url
  }
}

module "ecr-repo-fb-publisher-worker" {
  source = "github.com/ministryofjustice/cloud-platform-terraform-ecr-credentials?ref=7.0.0"

  team_name = "formbuilder"
  repo_name = "fb-publisher-worker"

  lifecycle_policy = var.lifecycle_policy

  oidc_providers      = ["circleci"]
  github_repositories = ["fb-publisher"]
  namespace           = var.namespace

  # Tags
  business_unit          = "Platforms"
  application            = "Form Builder"
  is_production          = "true"
  environment_name       = "production"
  infrastructure_support = "form-builder-developers@digital.justice.gov.uk"

  providers = {
    aws = aws.london
  }
}

resource "kubernetes_secret" "ecr-repo-fb-publisher-worker" {
  metadata {
    name      = "ecr-repo-fb-publisher-worker"
    namespace = "formbuilder-repos"
  }

  data = {
    repo_url = module.ecr-repo-fb-publisher-worker.repo_url
  }
}

##################################################

# Runner Node ECR Repos
module "ecr-repo-fb-runner-node" {
  source = "github.com/ministryofjustice/cloud-platform-terraform-ecr-credentials?ref=7.0.0"

  team_name = "formbuilder"
  repo_name = "fb-runner-node"

  lifecycle_policy = var.lifecycle_policy

  oidc_providers      = ["circleci"]
  github_repositories = ["fb-runner-node"]
  namespace           = var.namespace

  # Tags
  business_unit          = "Platforms"
  application            = "Form Builder"
  is_production          = "true"
  environment_name       = "production"
  infrastructure_support = "form-builder-developers@digital.justice.gov.uk"

  providers = {
    aws = aws.london
  }
}

resource "kubernetes_secret" "ecr-repo-fb-runner-node" {
  metadata {
    name      = "ecr-repo-fb-runner-node"
    namespace = "formbuilder-repos"
  }

  data = {
    repo_url = module.ecr-repo-fb-runner-node.repo_url
  }
}

########################################################

# Service Token Cache ECR Repos
module "ecr-repo-fb-service-token-cache" {
  source = "github.com/ministryofjustice/cloud-platform-terraform-ecr-credentials?ref=7.0.0"

  team_name = "formbuilder"
  repo_name = "fb-service-token-cache"

  lifecycle_policy = var.lifecycle_policy

  oidc_providers      = ["circleci"]
  github_repositories = ["fb-service-token-cache"]
  namespace           = var.namespace

  # Tags
  business_unit          = "Platforms"
  application            = "Form Builder"
  is_production          = "true"
  environment_name       = "production"
  infrastructure_support = "form-builder-developers@digital.justice.gov.uk"

  providers = {
    aws = aws.london
  }
}

resource "kubernetes_secret" "ecr-repo-fb-service-token-cache" {
  metadata {
    name      = "ecr-repo-fb-service-token-cache"
    namespace = "formbuilder-repos"
  }

  data = {
    repo_url = module.ecr-repo-fb-service-token-cache.repo_url
  }
}

########################################################

# Submitter ECR Repos
module "ecr-repo-fb-submitter-base" {
  source = "github.com/ministryofjustice/cloud-platform-terraform-ecr-credentials?ref=7.0.0"

  team_name = "formbuilder"
  repo_name = "fb-submitter-base"
  namespace = var.namespace

  lifecycle_policy = var.lifecycle_policy

  # Tags
  business_unit          = "Platforms"
  application            = "Form Builder"
  is_production          = "true"
  environment_name       = "production"
  infrastructure_support = "form-builder-developers@digital.justice.gov.uk"

  providers = {
    aws = aws.london
  }
}

resource "kubernetes_secret" "ecr-repo-fb-submitter-base" {
  metadata {
    name      = "ecr-repo-fb-submitter-base"
    namespace = "formbuilder-repos"
  }

  data = {
    repo_url = module.ecr-repo-fb-submitter-base.repo_url
  }
}

module "ecr-repo-fb-submitter-api" {
  source = "github.com/ministryofjustice/cloud-platform-terraform-ecr-credentials?ref=7.0.0"

  team_name = "formbuilder"
  repo_name = "fb-submitter-api"

  lifecycle_policy = var.lifecycle_policy

  oidc_providers      = ["circleci"]
  github_repositories = ["fb-submitter"]
  namespace           = var.namespace

  # Tags
  business_unit          = "Platforms"
  application            = "Form Builder"
  is_production          = "true"
  environment_name       = "production"
  infrastructure_support = "form-builder-developers@digital.justice.gov.uk"

  providers = {
    aws = aws.london
  }
}

resource "kubernetes_secret" "ecr-repo-fb-submitter-api" {
  metadata {
    name      = "ecr-repo-fb-submitter-api"
    namespace = "formbuilder-repos"
  }

  data = {
    repo_url = module.ecr-repo-fb-submitter-api.repo_url
  }
}

module "ecr-repo-fb-submitter-workers" {
  source = "github.com/ministryofjustice/cloud-platform-terraform-ecr-credentials?ref=7.0.0"

  team_name = "formbuilder"
  repo_name = "fb-submitter-workers"

  lifecycle_policy = var.lifecycle_policy

  oidc_providers      = ["circleci"]
  github_repositories = ["fb-submitter"]

  namespace = var.namespace

  # Tags
  business_unit          = "Platforms"
  application            = "Form Builder"
  is_production          = "true"
  environment_name       = "production"
  infrastructure_support = "form-builder-developers@digital.justice.gov.uk"

  providers = {
    aws = aws.london
  }
}

resource "kubernetes_secret" "ecr-repo-fb-submitter-workers" {
  metadata {
    name      = "ecr-repo-fb-submitter-workers"
    namespace = "formbuilder-repos"
  }

  data = {
    repo_url = module.ecr-repo-fb-submitter-workers.repo_url
  }
}

##################################################

# User Datastore ECR Repos
module "ecr-repo-fb-user-datastore-api" {
  source = "github.com/ministryofjustice/cloud-platform-terraform-ecr-credentials?ref=7.0.0"

  team_name = "formbuilder"
  repo_name = "fb-user-datastore-api"

  lifecycle_policy = var.lifecycle_policy

  oidc_providers      = ["circleci"]
  github_repositories = ["fb-user-datastore"]
  namespace           = var.namespace

  # Tags
  business_unit          = "Platforms"
  application            = "Form Builder"
  is_production          = "true"
  environment_name       = "production"
  infrastructure_support = "form-builder-developers@digital.justice.gov.uk"

  providers = {
    aws = aws.london
  }
}

resource "kubernetes_secret" "ecr-repo-fb-user-datastore-api" {
  metadata {
    name      = "ecr-repo-fb-user-datastore-api"
    namespace = "formbuilder-repos"
  }

  data = {
    repo_url = module.ecr-repo-fb-user-datastore-api.repo_url
  }
}

##################################################

# User Filestore ECR Repos
module "ecr-repo-fb-user-filestore-api" {
  source = "github.com/ministryofjustice/cloud-platform-terraform-ecr-credentials?ref=7.0.0"

  team_name = "formbuilder"
  repo_name = "fb-user-filestore-api"

  lifecycle_policy = var.lifecycle_policy

  oidc_providers      = ["circleci"]
  github_repositories = ["fb-user-filestore"]
  namespace           = var.namespace

  # Tags
  business_unit          = "Platforms"
  application            = "Form Builder"
  is_production          = "true"
  environment_name       = "production"
  infrastructure_support = "form-builder-developers@digital.justice.gov.uk"

  providers = {
    aws = aws.london
  }
}

resource "kubernetes_secret" "ecr-repo-fb-user-filestore-api" {
  metadata {
    name      = "ecr-repo-fb-user-filestore-api"
    namespace = "formbuilder-repos"
  }

  data = {
    repo_url = module.ecr-repo-fb-user-filestore-api.repo_url
  }
}

##################################################

# AV (Anti Virus) ECR Repos
module "ecr-repo-fb-av" {
  source = "github.com/ministryofjustice/cloud-platform-terraform-ecr-credentials?ref=7.0.0"

  team_name = "formbuilder"
  repo_name = "fb-av"

  lifecycle_policy = var.lifecycle_policy

  oidc_providers      = ["circleci"]
  github_repositories = ["fb-av"]
  namespace           = var.namespace

  # Tags
  business_unit          = "Platforms"
  application            = "Form Builder"
  is_production          = "true"
  environment_name       = "production"
  infrastructure_support = "form-builder-developers@digital.justice.gov.uk"

  providers = {
    aws = aws.london
  }
}

resource "kubernetes_secret" "ecr-repo-fb-av" {
  metadata {
    name      = "ecr-repo-fb-av"
    namespace = "formbuilder-repos"
  }

  data = {
    repo_url = module.ecr-repo-fb-av.repo_url
  }
}

##################################################

# fb-builder - docker image used to build form builder components
module "ecr-repo-fb-builder" {
  source = "github.com/ministryofjustice/cloud-platform-terraform-ecr-credentials?ref=7.0.0"

  team_name = "formbuilder"
  repo_name = "fb-builder"

  lifecycle_policy = var.lifecycle_policy

  oidc_providers = ["circleci"]

  github_repositories = ["fb-builder"]
  namespace           = var.namespace

  # Tags
  business_unit          = "Platforms"
  application            = "Form Builder"
  is_production          = "true"
  environment_name       = "production"
  infrastructure_support = "form-builder-developers@digital.justice.gov.uk"

  providers = {
    aws = aws.london
  }
}

resource "kubernetes_secret" "ecr-repo-fb-builder" {
  metadata {
    name      = "ecr-repo-fb-builder"
    namespace = "formbuilder-repos"
  }

  data = {
    repo_url = module.ecr-repo-fb-builder.repo_url
  }
}

##################################################

module "ecr-repo-fb-pdf-generator" {
  source = "github.com/ministryofjustice/cloud-platform-terraform-ecr-credentials?ref=7.0.0"

  team_name = "formbuilder"
  repo_name = "fb-pdf-generator"

  lifecycle_policy = var.lifecycle_policy

  oidc_providers      = ["circleci"]
  github_repositories = ["fb-pdf-generator"]
  namespace           = var.namespace

  # Tags
  business_unit          = "Platforms"
  application            = "Form Builder"
  is_production          = "true"
  environment_name       = "production"
  infrastructure_support = "form-builder-developers@digital.justice.gov.uk"
}

resource "kubernetes_secret" "ecr-repo-fb-pdf-generator" {
  metadata {
    name      = "ecr-repo-fb-pdf-generator"
    namespace = "formbuilder-repos"
  }

  data = {
    repo_url = module.ecr-repo-fb-pdf-generator.repo_url
  }
}

##################################################

module "ecr-repo-fb-base-adapter" {
  source = "github.com/ministryofjustice/cloud-platform-terraform-ecr-credentials?ref=7.0.0"

  team_name = "formbuilder"
  repo_name = "fb-base-adapter"

  lifecycle_policy = var.lifecycle_policy

  oidc_providers      = ["circleci"]
  github_repositories = ["fb-base-adapter"]
  namespace           = var.namespace

  # Tags
  business_unit          = "Platforms"
  application            = "Form Builder"
  is_production          = "true"
  environment_name       = "production"
  infrastructure_support = "form-builder-developers@digital.justice.gov.uk"
}

resource "kubernetes_secret" "ecr-repo-fb-base-adapter" {
  metadata {
    name      = "ecr-repo-fb-base-adapter"
    namespace = "formbuilder-repos"
  }

  data = {
    repo_url = module.ecr-repo-fb-base-adapter.repo_url
  }
}

##################################################

module "ecr-repo-hmcts-complaints-formbuilder-adapter-api" {
  source = "github.com/ministryofjustice/cloud-platform-terraform-ecr-credentials?ref=7.0.0"

  team_name = "formbuilder"
  repo_name = "hmcts-complaints-formbuilder-adapter-api"

  lifecycle_policy = var.lifecycle_policy

  oidc_providers      = ["circleci"]
  github_repositories = ["hmcts-complaints-formbuilder-adapter"]
  namespace           = var.namespace

  # Tags
  business_unit          = "Platforms"
  application            = "Form Builder"
  is_production          = "true"
  environment_name       = "production"
  infrastructure_support = "form-builder-developers@digital.justice.gov.uk"

  providers = {
    aws = aws.london
  }
}

resource "kubernetes_secret" "ecr-repo-hmcts-complaints-formbuilder-adapter-api" {
  metadata {
    name      = "ecr-repo-hmcts-complaints-formbuilder-adapter-api"
    namespace = "formbuilder-repos"
  }

  data = {
    repo_url = module.ecr-repo-hmcts-complaints-formbuilder-adapter-api.repo_url
  }
}

module "ecr-repo-hmcts-complaints-formbuilder-adapter-worker" {
  source = "github.com/ministryofjustice/cloud-platform-terraform-ecr-credentials?ref=7.0.0"

  team_name = "formbuilder"
  repo_name = "hmcts-complaints-formbuilder-adapter-worker"

  lifecycle_policy = var.lifecycle_policy

  oidc_providers      = ["circleci"]
  github_repositories = ["hmcts-complaints-formbuilder-adapter"]
  namespace           = var.namespace

  # Tags
  business_unit          = "Platforms"
  application            = "Form Builder"
  is_production          = "true"
  environment_name       = "production"
  infrastructure_support = "form-builder-developers@digital.justice.gov.uk"

  providers = {
    aws = aws.london
  }
}

resource "kubernetes_secret" "ecr-repo-hmcts-complaints-formbuilder-adapter-worker" {
  metadata {
    name      = "ecr-repo-hmcts-complaints-formbuilder-adapter-worker"
    namespace = "formbuilder-repos"
  }

  data = {
    repo_url = module.ecr-repo-hmcts-complaints-formbuilder-adapter-worker.repo_url
  }
}

##################################################

module "ecr-repo-fb-metadata-api" {
  source = "github.com/ministryofjustice/cloud-platform-terraform-ecr-credentials?ref=7.0.0"

  team_name = "formbuilder"
  repo_name = "fb-metadata-api"

  lifecycle_policy = var.lifecycle_policy

  oidc_providers      = ["circleci"]
  github_repositories = ["fb-metadata-api"]
  namespace           = var.namespace

  # Tags
  business_unit          = "Platforms"
  application            = "Form Builder"
  is_production          = "true"
  environment_name       = "production"
  infrastructure_support = "form-builder-developers@digital.justice.gov.uk"
}

resource "kubernetes_secret" "ecr-repo-fb-metadata-api" {
  metadata {
    name      = "ecr-repo-fb-metadata-api"
    namespace = "formbuilder-repos"
  }

  data = {
    repo_url = module.ecr-repo-fb-metadata-api.repo_url
  }
}

##################################################

module "ecr-repo-fb-editor-web" {
  source = "github.com/ministryofjustice/cloud-platform-terraform-ecr-credentials?ref=7.0.0"

  team_name = "formbuilder"
  repo_name = "fb-editor-web"

  lifecycle_policy = var.lifecycle_policy

  oidc_providers = ["circleci"]

  github_repositories = ["fb-editor"]
  namespace           = var.namespace

  # Tags
  business_unit          = "Platforms"
  application            = "Form Builder"
  is_production          = "true"
  environment_name       = "production"
  infrastructure_support = "form-builder-developers@digital.justice.gov.uk"
}

resource "kubernetes_secret" "ecr-repo-fb-editor-web" {
  metadata {
    name      = "ecr-repo-fb-editor-web"
    namespace = "formbuilder-repos"
  }

  data = {
    repo_url = module.ecr-repo-fb-editor-web.repo_url
  }
}

module "ecr-repo-fb-editor-workers" {
  source = "github.com/ministryofjustice/cloud-platform-terraform-ecr-credentials?ref=7.0.0"

  team_name = "formbuilder"
  repo_name = "fb-editor-workers"

  lifecycle_policy = var.lifecycle_policy

  oidc_providers = ["circleci"]

  github_repositories = ["fb-editor"]
  namespace           = var.namespace

  # Tags
  business_unit          = "Platforms"
  application            = "Form Builder"
  is_production          = "true"
  environment_name       = "production"
  infrastructure_support = "form-builder-developers@digital.justice.gov.uk"
}

resource "kubernetes_secret" "ecr-repo-fb-editor-workers" {
  metadata {
    name      = "ecr-repo-fb-editor-workers"
    namespace = "formbuilder-repos"
  }

  data = {
    repo_url = module.ecr-repo-fb-editor-workers.repo_url
  }
}
##################################################

module "ecr-repo-fb-runner" {
  source = "github.com/ministryofjustice/cloud-platform-terraform-ecr-credentials?ref=7.0.0"

  team_name = "formbuilder"
  repo_name = "fb-runner"

  lifecycle_policy = var.lifecycle_policy

  oidc_providers      = ["circleci"]
  github_repositories = ["fb-runner"]
  namespace           = var.namespace

  # Tags
  business_unit          = "Platforms"
  application            = "Form Builder"
  is_production          = "true"
  environment_name       = "production"
  infrastructure_support = "form-builder-developers@digital.justice.gov.uk"
}

resource "kubernetes_secret" "ecr-repo-fb-runner" {
  metadata {
    name      = "ecr-repo-fb-runner"
    namespace = "formbuilder-repos"
  }

  data = {
    repo_url = module.ecr-repo-fb-runner.repo_url
  }
}

##################################################

module "ecr-repo-fb-maintenance-page" {
  source = "github.com/ministryofjustice/cloud-platform-terraform-ecr-credentials?ref=7.0.0"

  team_name = "formbuilder"
  repo_name = "fb-maintenance-page"

  lifecycle_policy = var.lifecycle_policy

  oidc_providers      = ["circleci"]
  github_repositories = ["fb-maintenance-page"]
  namespace           = var.namespace

  # Tags
  business_unit          = "Platforms"
  application            = "Form Builder"
  is_production          = "true"
  environment_name       = "production"
  infrastructure_support = "form-builder-developers@digital.justice.gov.uk"
}

resource "kubernetes_secret" "ecr-repo-fb-maintenance-page" {
  metadata {
    name      = "ecr-repo-fb-maintenance-page"
    namespace = "formbuilder-repos"
  }

  data = {
    repo_url = module.ecr-repo-fb-maintenance-page.repo_url
  }
}

##################################################

module "ecr-repo-fb-adapter-template-api" {
  source = "github.com/ministryofjustice/cloud-platform-terraform-ecr-credentials?ref=7.0.0"

  team_name = "formbuilder"
  repo_name = "fb-adapter-template-api"

  lifecycle_policy = var.lifecycle_policy

  oidc_providers      = ["circleci"]
  github_repositories = ["fb-adapter-template"]
  namespace           = var.namespace

  # Tags
  business_unit          = "Platforms"
  application            = "Form Builder"
  is_production          = "true"
  environment_name       = "production"
  infrastructure_support = "form-builder-developers@digital.justice.gov.uk"

  providers = {
    aws = aws.london
  }
}

resource "kubernetes_secret" "ecr-repo-fb-adapter-template-api" {
  metadata {
    name      = "ecr-repo-fb-adapter-template-api"
    namespace = "formbuilder-repos"
  }

  data = {
    repo_url = module.ecr-repo-fb-adapter-template-api.repo_url
  }
}

module "ecr-repo-fb-adapter-template-worker" {
  source = "github.com/ministryofjustice/cloud-platform-terraform-ecr-credentials?ref=7.0.0"

  team_name = "formbuilder"
  repo_name = "fb-adapter-template-worker"

  lifecycle_policy = var.lifecycle_policy

  oidc_providers      = ["circleci"]
  github_repositories = ["fb-adapter-template"]
  namespace           = var.namespace

  # Tags
  business_unit          = "Platforms"
  application            = "Form Builder"
  is_production          = "true"
  environment_name       = "production"
  infrastructure_support = "form-builder-developers@digital.justice.gov.uk"

  providers = {
    aws = aws.london
  }
}

resource "kubernetes_secret" "ecr-repo-fb-adapter-template-worker" {
  metadata {
    name      = "ecr-repo-fb-adapter-template-worker"
    namespace = "formbuilder-repos"
  }

  data = {
    repo_url = module.ecr-repo-fb-adapter-template-worker.repo_url
  }
}

##################################################
