module "s3_bucket" {
  source                 = "github.com/ministryofjustice/cloud-platform-terraform-s3-bucket?ref=5.1.0"
  team_name              = var.team_name
  business_unit          = var.business_unit
  application            = var.application
  is_production          = var.is_production
  environment_name       = var.environment
  infrastructure_support = var.infrastructure_support
  namespace              = var.namespace
  versioning             = var.versioning

  lifecycle_rule = [
    {
      enabled = true

      noncurrent_version_transition = [
        {
          days          = var.s3_lifecycle_config["noncurrent_version_transition_days"]
          storage_class = "STANDARD_IA"
        },
        {
          days          = var.s3_lifecycle_config["noncurrent_version_transition_glacier_days"]
          storage_class = "GLACIER"
        },
      ]

      noncurrent_version_expiration = [
        {
          days = var.s3_lifecycle_config["noncurrent_version_expiration_days"]
        },
      ]
    }
  ]
}

resource "aws_iam_user" "alfresco_user" {
  name = "${var.namespace}-alfresco_user"
  path = "/system/${var.namespace}-alfresco_user/"
}

resource "aws_iam_access_key" "alfresco_user_access" {
  user = aws_iam_user.alfresco_user.name
}

resource "aws_iam_user_policy_attachment" "alfresco_user_policy" {
  policy_arn = module.s3_bucket.irsa_policy_arn
  user       = aws_iam_user.alfresco_user.name
}

resource "kubernetes_secret" "s3_bucket" {
  metadata {
    name      = "s3-bucket-output"
    namespace = var.namespace
  }

  data = {
    BUCKET_ARN  = module.s3_bucket.bucket_arn
    BUCKET_NAME = module.s3_bucket.bucket_name
    ACCESSKEY   = aws_iam_access_key.alfresco_user_access.id
    SECRETKEY   = aws_iam_access_key.alfresco_user_access.secret
  }
}


#######################################
# s3 bucket for OpenSearch snapshots
#######################################

module "s3_opensearch_snapshots_bucket" {
  source = "github.com/ministryofjustice/cloud-platform-terraform-s3-bucket?ref=5.1.0" # use the latest release

  # Tags
  business_unit          = var.business_unit
  application            = var.application
  is_production          = var.is_production
  team_name              = var.team_name
  namespace              = var.namespace
  environment_name       = var.environment
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
