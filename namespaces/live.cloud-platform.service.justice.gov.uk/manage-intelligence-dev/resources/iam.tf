resource "aws_iam_user" "ims_s3_user" {
  name = "manage-intelligence-dev-s3-user"
  path = "/system/manage-intelligence-dev-users/"
}

resource "aws_iam_access_key" "key_2024" {
  user = aws_iam_user.ims_s3_user.name
}

data "aws_iam_policy_document" "ims_user_s3_policy" {
  statement {
    actions = ["s3:PutObject", "s3:ListBucket", "s3:GetObject", "s3:DeleteObject"]

    resources = [
      module.ims_images_storage_bucket.bucket_arn,
      "${module.ims_images_storage_bucket.bucket_arn}/*",
      module.ims_attachments_storage_bucket.bucket_arn,
      "${module.ims_attachments_storage_bucket.bucket_arn}/*",
      module.mercury_data_entities_bucket.bucket_arn,
      "${module.mercury_data_entities_bucket.bucket_arn}/*",
      module.ims_dissemination_storage_bucket.bucket_arn,
      "${module.ims_dissemination_storage_bucket.bucket_arn}/*",
      module.ims_audit_files_storage_bucket.bucket_arn,
      "${module.ims_audit_files_storage_bucket.bucket_arn}/*"
    ]
  }

  statement {
    actions = [
      "kendra:GetQuerySuggestions",
      "kendra:Query",
      "kendra:Retrieve",
      "kendra:ListFaqs",
      "kendra:DeleteFaq",
      "kendra:DescribeFaq",
      "kendra:DescribeQuerySuggestionsConfig",
      "kendra:DeleteThesaurus",
      "kendra:CreateThesaurus",
      "kendra:CreateFaq",
      "kendra:ListThesauri",
      "kendra:ListDataSources",
      "kendra:DescribeThesaurus"
    ]

    resources = [
      aws_kendra_index.main.arn,
      "${aws_kendra_index.main.arn}/thesaurus/*",
      "${aws_kendra_index.main.arn}/faq/*"
    ]

  }

  statement {
    effect = "Deny"

    actions = ["s3:*"]

    resources = ["*"]

    condition {
      test     = "Bool"
      variable = "aws:SecureTransport"
      values   = ["false"]
    }
  }
}

resource "aws_iam_user_policy" "ims_user_s3_policy" {
  name   = "manage-intelligence-user-s3-policy-dev"
  policy = data.aws_iam_policy_document.ims_user_s3_policy.json
  user   = aws_iam_user.ims_s3_user.name
}

resource "kubernetes_secret" "ims_s3_kendra_user" {
  metadata {
    name      = "ims-s3-kendra-user-dev"
    namespace = var.namespace
  }

  data = {
    arn               = aws_iam_user.ims_s3_user.arn
    access_key_id     = aws_iam_access_key.key_2024.id
    secret_access_key = aws_iam_access_key.key_2024.secret
  }
}