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