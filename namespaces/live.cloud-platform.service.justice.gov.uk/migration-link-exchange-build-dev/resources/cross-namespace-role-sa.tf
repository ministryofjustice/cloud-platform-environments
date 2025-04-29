module "irsa" {
  source = "github.com/ministryofjustice/cloud-platform-terraform-irsa?ref=2.0.0"

  # EKS configuration
  eks_cluster_name = var.eks_cluster_name

  # IRSA configuration
  service_account_name = "${var.namespace}-service"
  namespace            = var.namespace

  # Policy ARNs
  role_policy_arns = [ aws_iam_policy.migration-link-exchange-build-dev-s3-policy.arn ]

  # Tags
  business_unit          = var.business_unit
  application            = var.application
  is_production          = var.is_production
  team_name              = var.team_name
  environment_name       = var.environment
  infrastructure_support = var.infrastructure_support
}




data "aws_iam_policy_document" "migration-link-exchange-build-dev-s3-policy" {
  # List & location for the S3 bucket.
  statement {
    actions = [ 
      "s3:ListBucket",
      "s3:GetBucketLocation"
    ]
    resources = [ 
      data.aws_ssm_parameter.s3-bucket-arn.value
    ]
  }
  # Read permissions for the resources path.
  statement {
    actions = [
      "s3:GetObject"
    ]
    resources = [
      "${data.aws_ssm_parameter.s3-bucket-arn.value}/resources/*",
    ]
  }
  # Read and write permissions for the build-status & build-output path.
  statement {
    actions = [
      "s3:GetObject",
      "s3:PutObject"
    ]
    resources = [
      "${data.aws_ssm_parameter.s3-bucket-arn.value}/build-status.json",
      "${data.aws_ssm_parameter.s3-bucket-arn.value}/build-output/*",
    ]
  }
}

resource "aws_iam_policy" "migration-link-exchange-build-dev-s3-policy" {
  name   = "migration-link-exchange-build-dev-s3-policy"
  policy = data.aws_iam_policy_document.migration-link-exchange-build-dev-s3-policy.json

  tags = {
    business-unit          = var.business_unit
    application            = var.application
    is-production          = var.is_production
    environment-name       = var.environment
    owner                  = var.team_name
    infrastructure-support = var.infrastructure_support
  }
}

# AWS SSM
# Get the AWS SSM parameter for the S3 bucket name and ARN

data "aws_ssm_parameter" "s3-bucket-name" {
  name = "/migration-link-exchange-dev/s3-bucket-name"
}

data "aws_ssm_parameter" "s3-bucket-arn" {
  name = "/migration-link-exchange-dev/s3-bucket-arn"
}

# Kubernetes secret for the S3 bucket

resource "kubernetes_secret" "s3_bucket" {
  metadata {
    name      = "s3-bucket-output"
    namespace = var.namespace
  }

  data = {
    # Reads the S3 bucket name from an SSM parameter
    bucket_name = data.aws_ssm_parameter.s3-bucket-name.value
  }
}
