resource "aws_iam_user" "bt_upload_user" {
  name = "hmpps-pin-phone-monitor-dev-bt-upload-user"
  path = "/system/hmpps-pin-phone-monitor-dev-upload-users/"
}

resource "aws_iam_access_key" "bt_upload_user_key" {
  user = aws_iam_user.bt_upload_user.name
}

data "aws_iam_policy_document" "bt_upload_policy" {
  statement {
    actions = ["s3:PutObject"]

    resources = [
      "${module.hmpps_pin_phone_monitor_document_s3_bucket.bucket_arn}/*.mp3",
      "${module.hmpps_pin_phone_monitor_document_s3_bucket.bucket_arn}/*.flac",
      "${module.hmpps_pin_phone_monitor_document_s3_bucket.bucket_arn}/*.wav",
      "${module.hmpps_pin_phone_monitor_document_s3_bucket.bucket_arn}/*.json"
    ]
  }

  statement {
    effect = "Deny"

    actions = ["s3:*"]

    resources = [
      module.hmpps_pin_phone_monitor_document_s3_bucket.bucket_arn,
      "${module.hmpps_pin_phone_monitor_document_s3_bucket.bucket_arn}/*"
    ]

    condition {
      test     = "Bool"
      variable = "aws:SecureTransport"
      values   = ["false"]
    }
  }
}

resource "aws_iam_user_policy" "bt_upload_policy" {
  name   = "hmpps-pin-phone-monitor-bt-upload-policy-dev"
  policy = data.aws_iam_policy_document.bt_upload_policy.json
  user   = aws_iam_user.bt_upload_user.name
}

resource "kubernetes_secret" "pcms_bt_upload_user" {
  metadata {
    name      = "pcms-bt-upload-user-dev"
    namespace = var.namespace
  }

  data = {
    arn               = aws_iam_user.bt_upload_user.arn
    access_key_id     = aws_iam_access_key.bt_upload_user_key.id
    secret_access_key = aws_iam_access_key.bt_upload_user_key.secret
  }
}

resource "random_id" "upload" {
  byte_length = 8
}

resource "aws_iam_user" "call_processing_user" {
  name = "pcms-call-processing-user-${random_id.upload.hex}"
  path = "/system/pcms-call-processing-users/"
}

resource "aws_iam_access_key" "call_processing_user_key" {
  user = aws_iam_user.call_processing_user.name
}

data "aws_iam_policy_document" "call_processing_policy" {
  statement {
    actions = ["s3:*Object"]

    resources = [
      "${module.hmpps_pin_phone_monitor_document_s3_bucket.bucket_arn}/*",
    ]
  }

  statement {
    actions = [
      "transcribe:*",
      "translate:*",
      "comprehend:DetectDominantLanguage",
      "comprehend:BatchDetectEntities",
      "comprehend:BatchDetectKeyPhrases"
    ]

    resources = [
      "*"
    ]
  }

  statement {
    actions = [
      "iam:PassRole"
    ]

    resources = [
      "*"
    ]

    condition {
      test     = "StringEquals"
      variable = "iam:PassedToService"
      values   = ["translate.amazonaws.com", "transcribe.amazonaws.com"]
    }
  }
}

resource "aws_iam_user_policy" "call_processing_policy" {
  name   = "pcms-call-processing-policy"
  policy = data.aws_iam_policy_document.call_processing_policy.json
  user   = aws_iam_user.call_processing_user.name
}

resource "kubernetes_secret" "pcms_call_processing_user" {
  metadata {
    name      = "pcms-call-processing-user"
    namespace = var.namespace
  }

  data = {
    access_key_id     = aws_iam_access_key.call_processing_user_key.id
    secret_access_key = aws_iam_access_key.call_processing_user_key.secret
  }
}
