module "irsa" {
  source = "github.com/ministryofjustice/cloud-platform-terraform-irsa?ref=2.0.0"

  # EKS configuration
  eks_cluster_name = var.eks_cluster_name

  # IRSA configuration
  service_account_name = "hale-platform-dev-service"
  namespace            = var.namespace # this is also used as a tag

  # Attach the approprate policies using a key => value map
  # If you're using Cloud Platform provided modules (e.g. SNS, S3), these
  # provide an output called `irsa_policy_arn` that can be used.
  role_policy_arns = {
    s3 = module.s3_bucket.irsa_policy_arn
    s3_lawcom = module.aws_iam_policy.tacticalproducts_lawcom_s3_policy.irsa_policy_arn,
    ecr = module.ecr_credentials.irsa_policy_arn,
    ecr2 = module.ecr_feed_parser.irsa_policy_arn,§
  }

  data "aws_iam_policy_document" "tacticalproducts_lawcom_s3_policy" {
    # Provide list of permissions and target AWS account resources to allow access to
    statement {
      actions = [
        "s3:ListBucket",
      ]
      resources = [
        "arn:aws:s3:::lawcom-prod-storage-11jsxou24uy7q",
     ]
    }
    statement {
      actions = [
        "s3:*",
      ]
      resources = [
        "arn:aws:s3:::lawcom-prod-storage-11jsxou24uy7q/*"
      ]
    }
  }

  resource "aws_iam_policy" "tacticalproducts_lawcom_s3_policy" {
  name   = "tacticalproducts_lawcom_s3_policy"
  policy = data.aws_iam_policy_document.tacticalproducts_lawcom_s3_policy.json

  tags = {
    business_unit          = var.business_unit
    application            = var.application
    is_production          = var.is_production
    team_name              = var.team_name
    environment_name       = var.environment
    infrastructure_support = var.infrastructure_support
    }
  }

  resource "kubernetes_secret" "lawcom_aws_secret" {
    metadata {
    name      = "lawcom-prod-s3-bucket"
    namespace = var.namespace
  }

  data = {
      bucket_arn = "arn:aws:s3:::lawcom-prod-storage-11jsxou24uy7q"
    }
  }

  # Tags
  business_unit          = var.business_unit
  application            = var.application
  is_production          = var.is_production
  team_name              = var.team_name
  environment_name       = var.environment
  infrastructure_support = var.infrastructure_support
}
