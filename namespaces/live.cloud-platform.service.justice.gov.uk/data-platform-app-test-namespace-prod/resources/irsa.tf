module "irsa" {
  eks_cluster_name = var.eks_cluster_name
  source           = "github.com/ministryofjustice/cloud-platform-terraform-irsa?ref=1.0.6"
  namespace        = "data-platform-app-test-namespace-prod"
  role_policy_arns = [aws_iam_policy.data-platform-app-test-namespace-prod.arn]
}

data "aws_iam_policy_document" "data-platform-app-test-namespace-prod" {
  statement {
    sid = "listbucket"
    actions = [
      "s3:ListBucket",
      "s3:GetBucketLocation",
    ]
    resources = [
      
      "",
      
    ]
  }

  statement {
    sid = "readwritebucket"
    actions = [
      "s3:GetObject",
      "s3:GetObjectAcl",
      "s3:GetObjectVersion",
      "s3:DeleteObject",
      "s3:DeleteObjectVersion",
      "s3:PutObject",
      "s3:PutObjectAcl",
      "s3:RestoreObject",
    ]
    resources = [
      
      "/*",
      
    ]
  }
}

resource "aws_iam_policy" "data-platform-app-test-namespace-prod" {
  name   = "data-platform-app-test-namespace-prod"
  policy = data.aws_iam_policy_document.data-platform-app-test-namespace-prod.json

  tags = {
    business-unit          = "testBusinessApp"
    application            = "test-app"
    is-production          = "true"
    environment-name       = "prod"
    owner                  = "testOwner"
    infrastructure-support = "test@test"
  }
}

resource "kubernetes_secret" "irsa" {
  metadata {
    name      = "irsa-output"
    namespace = "data-platform-app-test-namespace-prod"
  }
  data = {
    role           = module.irsa.aws_iam_role_arn
    serviceaccount = module.irsa.service_account_name.name
  }
}