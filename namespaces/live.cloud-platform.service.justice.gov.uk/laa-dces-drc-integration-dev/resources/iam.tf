data "aws_caller_identity" "current" {}
data "aws_guardduty_detector" "current" {}
data "aws_region" "current" {}

resource "aws_iam_user" "advantis_upload_user_dev" {
  name = "laa-dces-drc-integration-dev-advantis-upload-user"
  path = "/system/laa-dces-data-integration-dev-advantis-upload-users/"
}

resource "aws_iam_access_key" "advantis_upload_user_dev_key" {
  user = aws_iam_user.advantis_upload_user_dev.name
}

data "aws_iam_policy_document" "upload_policy" {

  statement {
    actions = [
      "s3:PutObject",
      "s3:GetObject",
      "s3:GetBucketLocation",
      "s3:ListBucket",
      "s3:ListObjectsV2",
      "s3:ListAllMyBuckets",
      "s3:ListMultipartUploadParts",
      "s3:AbortMultipartUpload"
    ]

    resources = [
      "${module.s3_advantis_bucket.bucket_arn}/DRC/*"
    ]
  }


  statement {
    effect    = "Deny"
    actions   = ["s3:*"]
    resources = [
      module.s3_advantis_bucket.bucket_arn,
      "${module.s3_advantis_bucket.bucket_arn}/*"
    ]

    condition {
      test     = "Bool"
      variable = "aws:SecureTransport"
      values   = ["false"]
    }
  }
}

resource "aws_iam_user_policy" "upload_policy" {
  name   = "laa-dces-data-integration-dev-advantis-upload-policy"
  policy = data.aws_iam_policy_document.upload_policy.json
  user   = aws_iam_user.advantis_upload_user_dev.name
}

resource "kubernetes_secret" "advantis_upload_user_dev" {
  metadata {
    name      = "advantis-upload-user-dev"
    namespace = var.namespace
  }

  data = {
    arn               = aws_iam_user.advantis_upload_user_dev.arn
    access_key_id     = aws_iam_access_key.advantis_upload_user_dev_key.id
    secret_access_key = aws_iam_access_key.advantis_upload_user_dev_key.secret
  }
}

resource "aws_iam_user" "admin_advantis_user_dev" {
  name = "laa-dces-data-integration-dev-admin-advantis-user"
  path = "/system/laa-dces-data-integration-dev-admin-advantis-users/"
}

resource "aws_iam_access_key" "admin_user_dev_key" {
  user = aws_iam_user.admin_advantis_user_dev.name
}

data "aws_iam_policy_document" "admin_policy" {
  statement {
    actions = [
      "s3:PutObject",
      "s3:DeleteObject",
      "s3:GetObject",
      "s3:GetBucketLocation",
      "s3:ListBucket",
      "s3:ListObjectsV2",
      "s3:ListAllMyBuckets",
      "s3:ListMultipartUploadParts",
      "s3:AbortMultipartUpload",
      "s3:GetObjectTagging"
    ]

    resources = [
      "${module.s3_advantis_bucket.bucket_arn}/*"
    ]
  }

  statement {
    actions = [
      "guardduty:ListDetectors",
      "guardduty:GetDetector",
      "guardduty:ListFindings",
      "guardduty:DescribeFindings",
      "guardduty:GetFindingsStatistics"
    ]

    resources = [
      "arn:aws:guardduty:${data.aws_region.current.name}:${data.aws_caller_identity.current.account_id}:detector/${data.aws_guardduty_detector.current.id}",
      "arn:aws:guardduty:${data.aws_region.current.name}:${data.aws_caller_identity.current.account_id}:detector/${data.aws_guardduty_detector.current.id}/findings"
    ]
  }



  statement {
    effect    = "Deny"
    actions   = ["s3:*"]
    resources = [
      module.s3_advantis_bucket.bucket_arn,
      "${module.s3_advantis_bucket.bucket_arn}/*"
    ]

    condition {
      test     = "Bool"
      variable = "aws:SecureTransport"
      values   = ["false"]
    }
  }
}


resource "aws_iam_user_policy" "admin_policy" {
  name   = "laa-dces-data-integration-dev-admin-advantis-policy"
  policy = data.aws_iam_policy_document.admin_policy.json
  user   = aws_iam_user.admin_advantis_user_dev.name
}

resource "kubernetes_secret" "admin-advantis-user_dev" {
  metadata {
    name      = "admin-advantis-user-dev"
    namespace = var.namespace
  }

  data = {
    arn               = aws_iam_user.admin_advantis_user_dev.arn
    access_key_id     = aws_iam_access_key.admin_user_dev_key.id
    secret_access_key = aws_iam_access_key.admin_user_dev_key.secret
  }
}




## IAM role for GuardDuty
resource "aws_iam_role" "guardduty_malware_protection_role" {
  name = "test-guard-duty-malware-protection-role"
  path = "/"
  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        "Effect" : "Allow",
        "Principal" : {
          "Service" : "malware-protection-plan.guardduty.amazonaws.com"
        },
        "Action" : "sts:AssumeRole",
        "Condition" : {
          "StringEquals" : {
            "aws:SourceAccount" : data.aws_caller_identity.current.account_id
          },
          "ArnLike" : {
            "aws:SourceArn" : "arn:aws:guardduty:eu-west-2:${data.aws_caller_identity.current.account_id}:malware-protection-plan/*"
          }
        }
      }
    ]
  })
}

## IAM policy
## Policy reference: https://docs.aws.amazon.com/guardduty/latest/ug/malware-protection-s3-iam-policy-prerequisite.html
resource "aws_iam_policy" "guard-duty_s3_custom" {
  name        = "guard-duty-s3-policy"
  description = "Policy allowing GuardDuty to manage S3 events, used for malware protection."

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid    = "AllowManagedRuleToSendS3EventsToGuardDuty"
        Effect = "Allow"
        Action = [
          "events:PutRule"
        ]
        Resource = [
          "arn:aws:events:eu-west-2:${data.aws_caller_identity.current.account_id}:rule/DO-NOT-DELETE-AmazonGuardDutyMalwareProtectionS3*"
        ]
        Condition = {
          StringEquals = {
            "events:ManagedBy" = "malware-protection-plan.guardduty.amazonaws.com"
          }
          "ForAllValues:StringEquals" = {
            "events:source" = "aws.s3"
            "events:detail-type" = [
              "Object Created",
              "AWS API Call via CloudTrail"
            ]
          }
          Null = {
            "events:source"      = "false"
            "events:detail-type" = "false"
          }
        }
      },

      {
        Sid    = "AllowGuardDutyToMonitorEventBridgeManagedRule"
        Effect = "Allow"
        Action = [
          "events:DescribeRule",
          "events:ListTargetsByRule"
        ]
        Resource = [
          "arn:aws:events:eu-west-2:${data.aws_caller_identity.current.account_id}:rule/DO-NOT-DELETE-AmazonGuardDutyMalwareProtectionS3*"
        ]
      },

      {
        Sid    = "AllowPostScanTag"
        Effect = "Allow"
        Action = [
          "s3:GetObjectTagging",
          "s3:GetObjectVersionTagging",
          "s3:PutObjectTagging",
          "s3:PutObjectVersionTagging"
        ]
        Resource = [
          "arn:aws:s3:::${module.s3_advantis_bucket.bucket_name}/*"
        ]
        Condition = {
          StringEquals = {
            "aws:ResourceAccount" = data.aws_caller_identity.current.account_id
          }
        }
      },

      {
        Sid    = "AllowEnableS3EventBridgeEvents"
        Effect = "Allow"
        Action = [
          "s3:PutBucketNotification",
          "s3:GetBucketNotification"
        ]
        Resource = [
          "arn:aws:s3:::${module.s3_advantis_bucket.bucket_name}"
        ]
        Condition = {
          StringEquals = {
            "aws:ResourceAccount" = data.aws_caller_identity.current.account_id
          }
        }
      },

      {
        Sid    = "AllowPutValidationObject"
        Effect = "Allow"
        Action = [
          "s3:PutObject"
        ]
        Resource = [
          "arn:aws:s3:::${module.s3_advantis_bucket.bucket_name}/malware-protection-resource-validation-object"
        ]
        Condition = {
          StringEquals = {
            "aws:ResourceAccount" = data.aws_caller_identity.current.account_id
          }
        }
      },

      {
        Sid    = "AllowCheckBucketOwnership"
        Effect = "Allow"
        Action = [
          "s3:ListBucket"
        ]
        Resource = [
          "arn:aws:s3:::${module.s3_advantis_bucket.bucket_name}"
        ]
        Condition = {
          StringEquals = {
            "aws:ResourceAccount" = data.aws_caller_identity.current.account_id
          }
        }
      },

      {
        Sid    = "AllowMalwareScan"
        Effect = "Allow"
        Action = [
          "s3:GetObject",
          "s3:GetObjectVersion"
        ]
        Resource = [
          "arn:aws:s3:::${module.s3_advantis_bucket.bucket_name}/*"
        ]
        Condition = {
          StringEquals = {
            "aws:ResourceAccount" = data.aws_caller_identity.current.account_id
          }
        }
      },

      ### This was copied from the console clickops testing
      {
        Sid    = "AllowUpdateTargetAndDeleteManagedRule"
        Effect = "Allow"
        Action = [
          "events:DeleteRule",
          "events:PutTargets",
          "events:RemoveTargets"
        ]
        Resource = [
          "arn:aws:events:eu-west-2:${data.aws_caller_identity.current.account_id}:rule/DO-NOT-DELETE-AmazonGuardDutyMalwareProtectionS3*"
        ]
        Condition = {
          StringEquals = {
            "events:ManagedBy" = "malware-protection-plan.guardduty.amazonaws.com"
          }
        }
      }

      ####  You will need below if you need to decrypt s3 bucket object with kms
      #   {
      #     Sid    = "AllowDecryptForMalwareScan"
      #     Effect = "Allow"
      #     Action = [
      #         "kms:GenerateDataKey",
      #         "kms:Decrypt"
      #     ]
      #     Resource = [
      #       your kms arn
      #     ]
      #     Condition = {
      #       StringEquals = {
      #         "kms:ViaService" = "s3.eu-west-2.amazonaws.com"
      #       }
      #     }
      #   }
    ]
  })
}

## Attach the IAM policy to the role
resource "aws_iam_role_policy_attachment" "attach_guardduty_s3_custom" {
  role       = aws_iam_role.guardduty_malware_protection_role.name
  policy_arn = aws_iam_policy.guard-duty_s3_custom.arn
}