resource "aws_iam_user" "ims_debug_user" {
  name = "hmpps-manage-intelligence-preprod-ldebug-user"
  path = "/system/hmpps-manage-intelligence-preprod-users/"
}

resource "aws_iam_access_key" "debug_key_2023" {
  user = aws_iam_user.ims_debug_user.name
}

data "aws_iam_policy_document" "ims_legacy_debug_policy" {
  statement {
    actions = ["*"]

    resources = [
      module.manage_intelligence_extractor_bucket.bucket_arn,
      "${module.manage_intelligence_extractor_bucket.bucket_arn}/*",
      module.ims_extractor_queue.sqs_arn
    ]
  }

  statement {
    effect = "Deny"

    actions = ["s3:*"]

    resources = [
      module.manage_intelligence_extractor_bucket.bucket_arn,
      "${module.manage_intelligence_extractor_bucket.bucket_arn}/*"
    ]

    condition {
      test     = "Bool"
      variable = "aws:SecureTransport"
      values   = ["false"]
    }
  }
}

resource "aws_iam_user_policy" "ims_debug_policy" {
  name   = "hmpps-manage-intelligence-legacy-debug-policy-preprod"
  policy = data.aws_iam_policy_document.ims_legacy_debug_policy.json
  user   = aws_iam_user.ims_debug_user.name
}

resource "kubernetes_secret" "ims_legacy_debug_user" {
  metadata {
    name      = "ims-debug-user-preprod"
    namespace = var.namespace
  }

  data = {
    arn               = aws_iam_user.ims_debug_user.arn
    access_key_id     = aws_iam_access_key.debug_key_2023.id
    secret_access_key = aws_iam_access_key.debug_key_2023.secret
  }
}