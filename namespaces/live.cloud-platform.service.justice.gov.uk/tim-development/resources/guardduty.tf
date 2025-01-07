data "aws_caller_identity" "current" {}

## IAM role for GuardDuty
resource "aws_iam_role" "guardduty_malware_protection_role" {
  name = "test-guardduty-malware-protection-role"
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
            "aws:SourceAccount" : "${data.aws_caller_identity.current.account_id}"
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
resource "aws_iam_policy" "guardduty_s3_custom" {
  name        = "guardduty-s3-policy"
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
          "arn:aws:s3:::${module.s3_bucket.bucket_name}/*"
        ]
        Condition = {
          StringEquals = {
            "aws:ResourceAccount" = "${data.aws_caller_identity.current.account_id}"
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
          "arn:aws:s3:::${module.s3_bucket.bucket_name}"
        ]
        Condition = {
          StringEquals = {
            "aws:ResourceAccount" = "${data.aws_caller_identity.current.account_id}"
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
          "arn:aws:s3:::${module.s3_bucket.bucket_name}/malware-protection-resource-validation-object"
        ]
        Condition = {
          StringEquals = {
            "aws:ResourceAccount" = "${data.aws_caller_identity.current.account_id}"
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
          "arn:aws:s3:::${module.s3_bucket.bucket_name}"
        ]
        Condition = {
          StringEquals = {
            "aws:ResourceAccount" = "${data.aws_caller_identity.current.account_id}"
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
          "arn:aws:s3:::${module.s3_bucket.bucket_name}/*"
        ]
        Condition = {
          StringEquals = {
            "aws:ResourceAccount" = "${data.aws_caller_identity.current.account_id}"
          }
        }
      },

      ### This was copied from the console 
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
  policy_arn = aws_iam_policy.guardduty_s3_custom.arn
}


## Enable Malware Protection on the new test bucket
resource "aws_guardduty_malware_protection_plan" "test_malware_plan" {
  role = aws_iam_role.guardduty_malware_protection_role.arn

  protected_resource {
    s3_bucket {
      bucket_name = module.s3_bucket.bucket_name
    }
  }

  actions {
    tagging {
      status = "ENABLED"
    }
  }

  tags = {
    Name = "GuardDutyMalwareProtectionPlan-${module.s3_bucket.bucket_name}"
  }
}