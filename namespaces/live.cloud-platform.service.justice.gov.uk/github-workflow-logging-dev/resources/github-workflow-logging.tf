# ── S3: workflow log snapshots ────────────────────────────────────────────────

module "snapshots_bucket" {
  source = "github.com/ministryofjustice/cloud-platform-terraform-s3-bucket?ref=5.3.0"

  acl           = "private"
  business_unit = var.business_unit
  team_name     = var.team_name
  application   = var.application

  namespace              = var.namespace
  environment_name       = var.environment_name
  is_production          = var.is_production
  infrastructure_support = var.infrastructure_support

  versioning = true
}

# ── S3: backfill worker cursor state ─────────────────────────────────────────

module "backfill_state_bucket" {
  source = "github.com/ministryofjustice/cloud-platform-terraform-s3-bucket?ref=5.3.0"

  acl           = "private"
  business_unit = var.business_unit
  team_name     = var.team_name
  application   = "${var.application}-backfill-state"

  namespace              = var.namespace
  environment_name       = var.environment_name
  is_production          = var.is_production
  infrastructure_support = var.infrastructure_support

  versioning = true
}

# ── OpenSearch: log index cluster ────────────────────────────────────────────

module "opensearch" {
  source = "github.com/ministryofjustice/cloud-platform-terraform-opensearch?ref=1.8.1"

  business_unit          = var.business_unit
  application            = var.application
  is_production          = var.is_production
  team_name              = var.team_name
  namespace              = var.namespace
  environment_name       = var.environment_name
  infrastructure_support = var.infrastructure_support

  snapshot_bucket_arn = module.snapshots_bucket.bucket_arn

  cluster_config = {
    instance_count = 2
    instance_type  = "t3.medium.search"
  }

  ebs_options = {
    volume_size = 400
  }
}

# ── Service account: deploy credentials for GitHub Actions ───────────────────
#
# Publishes to ministryofjustice/ministry-of-justice-github-analysis:
#   Secrets: KUBE_CERT, KUBE_TOKEN, KUBE_CLUSTER, KUBE_NAMESPACE
#
module "deploy_serviceaccount" {
  source = "github.com/ministryofjustice/cloud-platform-terraform-serviceaccount?ref=1.2.0"

  namespace          = var.namespace
  kubernetes_cluster = var.kubernetes_cluster

  serviceaccount_name = "github-workflow-logging-deployer"
  role_name           = "github-workflow-logging-deployer-role"
  rolebinding_name    = "github-workflow-logging-deployer-rb"

  github_repositories = var.github_actions_repositories
  github_environments = var.github_actions_environments

  serviceaccount_rules = [
    {
      api_groups = [""]
      resources = [
        "pods/portforward",
        "deployment",
        "secrets",
        "services",
        "configmaps",
        "pods",
      ]
      verbs = [
        "patch",
        "get",
        "create",
        "update",
        "delete",
        "list",
        "watch",
      ]
    },
    {
      api_groups = [
        "extensions",
        "apps",
        "batch",
        "networking.k8s.io",
        "policy",
      ]
      resources = [
        "deployments",
        "ingresses",
        "cronjobs",
        "jobs",
        "replicasets",
        "poddisruptionbudgets",
        "networkpolicies",
      ]
      verbs = [
        "get",
        "update",
        "delete",
        "create",
        "patch",
        "list",
        "watch",
      ]
    },
    {
      api_groups = [
        "monitoring.coreos.com",
      ]
      resources = [
        "prometheusrules",
        "servicemonitors",
      ]
      verbs = [
        "*",
      ]
    },
    {
      api_groups = [
        "autoscaling",
      ]
      resources = [
        "hpa",
        "horizontalpodautoscalers",
      ]
      verbs = [
        "get",
        "update",
        "delete",
        "create",
        "patch",
      ]
    },
  ]

  # Bump this date to force rotation of the token published to GitHub Actions.
  # serviceaccount_token_rotated_date = "25-03-2026"
}

# ── ECR: container image repository ──────────────────────────────────────────
#
# Publishes to ministryofjustice/ministry-of-justice-github-analysis:
#   Secrets:   ECR_ROLE_TO_ASSUME, ECR_REGISTRY_URL
#   Variables: ECR_REGION, ECR_REPOSITORY
#
module "container_repository" {
  source = "github.com/ministryofjustice/cloud-platform-terraform-ecr-credentials?ref=8.0.0"

  repo_name = var.application

  oidc_providers      = ["github"]
  github_repositories = var.github_actions_repositories
  github_environments = var.github_actions_environments

  business_unit          = var.business_unit
  application            = var.application
  is_production          = var.is_production
  team_name              = var.team_name
  namespace              = var.namespace
  environment_name       = var.environment_name
  infrastructure_support = var.infrastructure_support
}

