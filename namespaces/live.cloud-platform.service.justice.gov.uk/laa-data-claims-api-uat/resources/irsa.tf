module "irsa" {
  source = "github.com/ministryofjustice/cloud-platform-terraform-irsa?ref=2.1.0"
  eks_cluster_name = var.eks_cluster_name
  service_account_name = "irsa-sqs-${var.namespace}"
  namespace            = var.namespace

  role_policy_arns = {
    sqs = module.sqs_queue.irsa_policy_arn
    gpfd_s3 = aws_iam_policy.upload_to_s3_bucket_in_gpfd_dev_namespace_policy.arn
  }
  business_unit          = var.business_unit
  application            = var.application
  is_production          = var.is_production
  team_name              = var.team_name
  environment_name       = var.environment
  infrastructure_support = var.infrastructure_support
}

resource "kubernetes_secret" "irsa" {
  metadata {
    name      = "${var.namespace}-irsa"
    namespace = var.namespace
  }
  data = {
    role           = module.irsa.role_name
    serviceaccount = module.irsa.service_account.name
    rolearn        = module.irsa.role_arn
  }
}

resource "kubernetes_secret" "sqs_queue_arn" {
  metadata {
    name      = "${var.namespace}-sqs-arn"
    namespace = var.namespace
  }
  data = {
    arn = module.sqs_queue.sqs_queue_arn
  }
}

data "aws_iam_policy_document" "upload_to_s3_bucket_in_gpfd_dev_namespace" {
  statement {
    actions = [
      "s3:PutObject",
    ]
    resources = [
      "arn:aws:s3:::laa-get-payments-finance-data-dev-report-store/*",
    ]
  }
}

resource "aws_iam_policy" "upload_to_s3_bucket_in_gpfd_dev_namespace_policy" {
  name   = "upload_to_s3_bucket_in_gpfd_dev_namespace_policy"
  policy = data.aws_iam_policy_document.upload_to_s3_bucket_in_gpfd_dev_namespace.json

  tags = {
    business-unit          = var.business_unit
    application            = var.application
    is-production          = var.is_production
    environment-name       = var.environment
    owner                  = var.team_name
    infrastructure-support = var.infrastructure_support
  }
}