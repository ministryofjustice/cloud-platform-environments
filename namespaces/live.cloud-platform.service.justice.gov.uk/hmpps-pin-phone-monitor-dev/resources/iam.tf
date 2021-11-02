resource "random_id" "upload" {
  byte_length = 8
}

resource "aws_iam_user" "upload_user" {
  name = "hmpps-pin-phone-monitor-upload-user-${random_id.upload.hex}"
  path = "/system/hmpps-pin-phone-monitor-upload-users/"
}

resource "aws_iam_access_key" "upload_user" {
  user = aws_iam_user.upload_user.name
}

data "aws_iam_policy_document" "upload_policy" {
  statement {
    actions = ["s3:PutObject"]

    resources = [
      "${module.hmpps_pin_phone_monitor_document_s3_bucket.bucket_arn}/*.mp3",
      "${module.hmpps_pin_phone_monitor_document_s3_bucket.bucket_arn}/*.flac",
      "${module.hmpps_pin_phone_monitor_document_s3_bucket.bucket_arn}/*.wav",
      "${module.hmpps_pin_phone_monitor_document_s3_bucket.bucket_arn}/*.xml",
      "${module.hmpps_pin_phone_monitor_document_s3_bucket.bucket_arn}/*.json"
    ]
  }

  statement {
    effect = "Deny"

    actions = ["s3:*"]

    resources = [
      "${module.hmpps_pin_phone_monitor_document_s3_bucket.bucket_arn}",
      "${module.hmpps_pin_phone_monitor_document_s3_bucket.bucket_arn}/*"
    ]

    condition {
      test     = "Bool"
      variable = "aws:SecureTransport"
      values   = ["false"]
    }
  }
}

resource "aws_iam_user_policy" "upload_policy" {
  name   = "hmpps-pin-phone-monitor-upload-policy"
  policy = data.aws_iam_policy_document.upload_policy.json
  user   = aws_iam_user.upload_user.name
}

resource "kubernetes_secret" "hmpps_pin_phone_monitor_upload_user" {
  metadata {
    name      = "hmpps-pin-phone-monitor-upload-user"
    namespace = var.namespace
  }

  data = {
    hmpps_pin_phone_monitor_upload_user_arn               = aws_iam_user.upload_user.arn
    hmpps_pin_phone_monitor_upload_user_access_key_id     = aws_iam_access_key.upload_user.id
    hmpps_pin_phone_monitor_upload_user_secret_access_key = aws_iam_access_key.upload_user.secret
  }
}

resource "aws_iam_user" "call_processing_user" {
  name = "hmpps-pin-phone-monitor-call-processing-user-${random_id.upload.hex}"
  path = "/system/hmpps-pin-phone-monitor-call-processing-users/"
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
      "comprehend:DetectDominantLanguage"
    ]

    resources = [
      "*"
    ]
  }
}

resource "aws_iam_user_policy" "call_processing_policy" {
  name   = "hmpps-pin-phone-monitor-call-processing-policy"
  policy = data.aws_iam_policy_document.call_processing_policy.json
  user   = aws_iam_user.call_processing_user.name
}

resource "kubernetes_secret" "hmpps_pin_phone_monitor_call_processing_user" {
  metadata {
    name      = "hmpps-pin-phone-monitor-call-processing-user"
    namespace = var.namespace
  }

  data = {
    hmpps_pin_phone_call_processing_user_access_key_id     = aws_iam_access_key.call_processing_user_key.id
    hmpps_pin_phone_call_processing_user_secret_access_key = aws_iam_access_key.call_processing_user_key.secret
  }
}
