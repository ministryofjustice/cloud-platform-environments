resource "aws_iam_user" "bt_upload_user" {
  name = "hmpps-pin-phone-monitor-qa-bt-upload-user"
  path = "/system/hmpps-pin-phone-monitor-qa-upload-users/"
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

resource "aws_iam_user_policy" "bt_upload_policy" {
  name   = "hmpps-pin-phone-monitor-bt-upload-policy-qa"
  policy = data.aws_iam_policy_document.bt_upload_policy.json
  user   = aws_iam_user.bt_upload_user.name
}

resource "kubernetes_secret" "hmpps_pin_phone_monitor_bt_upload_user" {
  metadata {
    name      = "hmpps-pin-phone-monitor-bt-upload-user-qa"
    namespace = var.namespace
  }

  data = {
    hmpps_pin_phone_monitor_upload_user_arn               = aws_iam_user.bt_upload_user.arn
    hmpps_pin_phone_monitor_upload_user_access_key_id     = aws_iam_access_key.bt_upload_user_key.id
    hmpps_pin_phone_monitor_upload_user_secret_access_key = aws_iam_access_key.bt_upload_user_key.secret
  }
}

