resource "aws_iam_user" "ims_extractor_user" {
  name = "hmpps-manage-intelligence-stage-extractor-user"
  path = "/system/hmpps-manage-intelligence-stage-users/"
}

resource "aws_iam_access_key" "key_2023" {
  user = aws_iam_user.ims_extractor_user.name
}

data "aws_iam_policy_document" "ims_legacy_extractor_policy" {
  statement {
    actions = ["s3:PutObject", "s3:ListBucket", "s3:GetObject", "s3:DeleteObject"]

    resources = [
      module.ims_images_storage_bucket.bucket_arn,
      "${module.ims_images_storage_bucket.bucket_arn}/*",
      module.ims_attachments_storage_bucket.bucket_arn,
      "${module.ims_attachments_storage_bucket.bucket_arn}/*",
      module.mercury_data_entities_bucket.bucket_arn,
      "${module.mercury_data_entities_bucket.bucket_arn}/*"
    ]
  }

  statement {
    actions = ["s3:PutObject", "sqs:SendMessage", "sqs:GetQueueUrl"]

    resources = [
      module.manage_intelligence_extractor_bucket.bucket_arn,
      "${module.manage_intelligence_extractor_bucket.bucket_arn}/*",
      module.ims_extractor_queue.sqs_arn,
      module.ims_extractor_dead_letter_queue.sqs_arn,
      module.attachment_metadata_extractor_queue.sqs_arn,
      module.attachment_metadata_extractor_dead_letter_queue.sqs_arn
    ]
  }

  statement {
    effect = "Deny"

    actions = ["s3:*"]

    resources = [
      module.manage_intelligence_extractor_bucket.bucket_arn,
      "${module.manage_intelligence_extractor_bucket.bucket_arn}/*",
      module.ims_images_storage_bucket.bucket_arn,
      "${module.ims_images_storage_bucket.bucket_arn}/*",
      module.ims_attachments_storage_bucket.bucket_arn,
      "${module.ims_attachments_storage_bucket.bucket_arn}/*"
    ]

    condition {
      test     = "Bool"
      variable = "aws:SecureTransport"
      values   = ["false"]
    }
  }
}

resource "aws_iam_user_policy" "ims_extractor_policy" {
  name   = "hmpps-manage-intelligence-legacy-extractor-policy-stage"
  policy = data.aws_iam_policy_document.ims_legacy_extractor_policy.json
  user   = aws_iam_user.ims_extractor_user.name
}

resource "kubernetes_secret" "ims_legacy_extractor_user" {
  metadata {
    name      = "ims-extractor-user-stage"
    namespace = var.namespace
  }

  data = {
    arn               = aws_iam_user.ims_extractor_user.arn
    access_key_id     = aws_iam_access_key.key_2023.id
    secret_access_key = aws_iam_access_key.key_2023.secret
  }
}