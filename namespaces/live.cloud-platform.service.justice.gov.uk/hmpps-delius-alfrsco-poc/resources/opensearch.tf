module "opensearch" {
  source = "github.com/ministryofjustice/cloud-platform-terraform-opensearch?ref=1.8.0" # use the latest release

  # VPC/EKS configuration
  vpc_name         = var.vpc_name
  eks_cluster_name = var.eks_cluster_name

  # Cluster configuration
  engine_version      = "OpenSearch_1.3"
  snapshot_bucket_arn = module.s3_opensearch_snapshots_bucket.bucket_arn
  # Non-production cluster configuration
  cluster_config = {
    instance_count = 2
    instance_type  = "m6g.xlarge.search"
  }

  ebs_options = {
    volume_size = 20
  }

  advanced_options = {
    # increase the maxClauseCount to 4096
    "indices.query.bool.max_clause_count" = "4096"
  }
  # Tags
  business_unit          = var.business_unit
  application            = var.application
  is_production          = var.is_production
  team_name              = var.team_name
  namespace              = var.namespace
  environment_name       = var.environment_name
  infrastructure_support = var.infrastructure_support
}

# Output the OpenSearch details
resource "kubernetes_secret" "opensearch" {
  metadata {
    name      = "opensearch-output"
    namespace = var.namespace
  }

  data = {
    PROXY_URL         = module.opensearch.proxy_url
    SNAPSHOT_ROLE_ARN = module.opensearch.snapshot_role_arn
  }
}

#######################################
# s3 bucket for OpenSearch snapshots
#######################################

module "s3_opensearch_snapshots_bucket" {
  source = "github.com/ministryofjustice/cloud-platform-terraform-s3-bucket?ref=5.3.0" # use the latest release

  # Tags
  business_unit          = var.business_unit
  application            = var.application
  is_production          = var.is_production
  team_name              = var.team_name
  namespace              = var.namespace
  environment_name       = var.environment_name
  infrastructure_support = var.infrastructure_support
}

resource "kubernetes_secret" "s3_opensearch_snapshots_bucket" {
  metadata {
    name      = "s3-opensearch-snapshots-bucket-output"
    namespace = var.namespace
  }

  data = {
    BUCKET_ARN  = module.s3_opensearch_snapshots_bucket.bucket_arn
    BUCKET_NAME = module.s3_opensearch_snapshots_bucket.bucket_name
    ACCESSKEY   = aws_iam_access_key.opensearch_snapshots.id
    SECRETKEY   = aws_iam_access_key.opensearch_snapshots.secret
  }
}

resource "aws_iam_user" "opensearch_snapshots" {
  name = "${var.namespace}-opensearch_snapshots_user"
  path = "/system/${var.namespace}-opensearch_snapshots_user/"
}

resource "aws_iam_access_key" "opensearch_snapshots" {
  user = aws_iam_user.opensearch_snapshots.name
}

resource "aws_iam_user_policy_attachment" "opensearch_snapshots" {
  policy_arn = module.s3_opensearch_snapshots_bucket.irsa_policy_arn
  user       = aws_iam_user.opensearch_snapshots.name
}

data "kubernetes_secret" "s3_opensearch_snapshots_bucket_dev" {
  metadata {
    name      = "s3-opensearch-snapshots-bucket-output-dev"
    namespace = var.namespace
  }
}
