data "aws_caller_identity" "current" {}

data "aws_region" "current" {}

data "aws_iam_policy_document" "s3_access_policy" {
  statement {
    sid = "AllowS3ObjectOperations"
    actions = [
      "s3:GetObject",
      "s3:PutObject",
      "s3:DeleteObject",
    ]
    resources = [
      "${module.s3_bucket.bucket_arn}/*"
    ]
  }

  statement {
    sid = "AllowS3ListBucket"
    actions = [
      "s3:ListBucket",
    ]
    resources = [
      module.s3_bucket.bucket_arn,
    ]
  }
}

data "aws_iam_policy_document" "irsa_trust_policy" {
  statement {
    effect = "Allow"
    principals {
      type        = "Federated"
      identifiers = ["arn:aws:iam::${data.aws_caller_identity.current.account_id}:oidc-provider/${replace(var.cluster_oidc_issuer_url, "https://", "")}"]
    }
    actions = ["sts:AssumeRoleWithWebIdentity"]
    condition {
      test     = "StringEquals"
      variable = "${replace(var.cluster_oidc_issuer_url, "https://", "")}:sub"
      values   = ["system:serviceaccount:${var.namespace}:${var.service_account_name}"]
    }
    condition {
      test     = "StringEquals"
      variable = "${replace(var.cluster_oidc_issuer_url, "https://", "")}:aud"
      values   = ["sts.amazonaws.com"]
    }
  }
}

resource "aws_iam_role" "s3_role" {
  name               = "s3-bucket-role-${var.namespace}"
  assume_role_policy = data.aws_iam_policy_document.irsa_trust_policy.json
}

resource "aws_iam_role_policy" "s3_policy" {
  name   = "s3-access-policy"
  role   = aws_iam_role.s3_role.id
  policy = data.aws_iam_policy_document.s3_access_policy.json
}

resource "kubernetes_service_account" "s3_sa" {
  metadata {
    name      = var.service_account_name
    namespace = var.namespace
    annotations = {
      "eks.amazonaws.com/role-arn" = aws_iam_role.s3_role.arn
    }
  }
}
