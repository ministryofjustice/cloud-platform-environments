## IAM role for GuardDuty
resource "aws_iam_role" "guardduty_malware_protection_role" {
  name               = "test-guardduty-malware-protection-role"
  path               = "/"
  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Effect = "Allow",
        Principal = {
          Service = "guardduty.amazonaws.com"
        },
        Action = "sts:AssumeRole"
      }
    ]
  })
}


## IAM policy
data "aws_iam_policy_document" "guardduty_s3_limited" {
  statement {
    sid     = "AllowListAllMyBuckets"
    effect  = "Allow"
    actions = ["s3:ListAllMyBuckets"]
    resources = ["*"]
  }

  statement {
    sid    = "GuardDutyS3MalwareProtectionLimited"
    effect = "Allow"
    actions = [
      "s3:GetObject",
      "s3:GetObjectAcl",
      "s3:GetObjectTagging",
      "s3:GetObjectVersion",
      "s3:GetObjectVersionAcl",
      "s3:GetObjectVersionTagging",
      "s3:ListBucket",
      "s3:GetBucketAcl",
      "s3:GetBucketPolicy",
      "s3:GetBucketLocation",
      "s3:GetBucketPolicyStatus"
    ]
    resources = [
      "arn:aws:s3:::${module.s3_test_bucket.bucket_name}",
      "arn:aws:s3:::${module.s3_test_bucket.bucket_name}/*"
    ]
  }
}

resource "aws_iam_policy" "guardduty_s3_custom" {
  name   = "MyCustomGuardDutyMalwarePolicy"
  policy = data.aws_iam_policy_document.guardduty_s3_custom.json
}

## Attach the IAM policy to the role
resource "aws_iam_role_policy_attachment" "attach_guardduty_s3_custom" {
  role       = aws_iam_role.guardduty_malware_role.name
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