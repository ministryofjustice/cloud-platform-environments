module "s3_advantis_bucket" {
  source = "github.com/ministryofjustice/cloud-platform-terraform-s3-bucket?ref=5.3.0"

  team_name              = var.team_name
  business_unit          = var.business_unit
  application            = var.application
  is_production          = var.is_production
  environment_name       = var.environment
  infrastructure_support = var.infrastructure_support
  namespace              = var.namespace
  versioning             = true

  providers = {
    aws = aws.london
  }

  bucket_policy = data.aws_iam_policy_document.bucket-policy.json

}


data "aws_iam_policy_document" "bucket-policy" {
  statement {
    principals {
      type        = "AWS"
      identifiers = [
        aws_iam_user.advantis_upload_user_dev.arn
      ]
    }
    actions = [
      "s3:GetBucketLocation",
      "s3:ListBucket",
      "s3:GetObject",
      "s3:GetObjectAcl"
    ]
    resources = [
      "$${bucket_arn}",
      "$${bucket_arn}/*"
    ]

  }

  statement {
    principals {
      type        = "AWS"
      identifiers = [
        aws_iam_user.admin_advantis_user_dev.arn
      ]
    }
    actions = [
      "s3:GetBucketLocation",
      "s3:ListBucket",
      "s3:GetObject",
      "s3:GetObjectAcl"
    ]
    resources = [
      "$${bucket_arn}",
      "$${bucket_arn}/*"
    ]
  }



  # Delegate S3 Access for Cross-Account Sync
  statement {
    sid = "DelegateS3Access"
    effect = "Allow"
    principals {
      type        = "AWS"
      identifiers = [
        "arn:aws:iam::463470948902:user/prodadvlaadatamigr"
      ]
    }
    actions = [
      "s3:ListBucket",
      "s3:GetObject",
      "s3:GetObjectAcl",
      "s3:GetObjectTagging"
    ]
    resources = [
      "$${bucket_arn}",
      "$${bucket_arn}/*"
    ]
  }

  statement {
    principals {
      type        = "AWS"
      identifiers = [
        "arn:aws:iam::463470948902:user/prodadvlaadatamigr"
      ]
    }
    effect = "Deny"
    actions = [
      "s3:GetObject",
      "s3:GetObjectAcl",
      "s3:GetObjectTagging"
    ]
    resources = [
      "$${bucket_arn}/DRC/Attachments/*"  # Deny getting objects from DRC/Attachments
    ]
  }





  statement {
    effect = "Allow"
    principals {
      type        = "AWS"
      identifiers = [
        aws_iam_role.guardduty_malware_protection_role.arn
      ]
    }
    actions = [
      "s3:GetObject",
      "s3:ListBucket",
      "s3:GetBucketPolicy",
      "s3:GetBucketAcl",
      "s3:GetBucketLocation"
    ]
    resources = [
      "$${bucket_arn}",
      "$${bucket_arn}/*"
    ]
  }



  # s3 put access to transfer attachments from marston bucket
  statement {
    sid = "PutAccessForMarstonAttachments"
    effect = "Allow"
    principals {
      type        = "AWS"
      identifiers = [
         "arn:aws:iam::754256621582:user/system/laa-dces-data-migration-dev-admin-users/laa-dces-data-migration-dev-admin-user"
      ]
    }
    actions = [
      "s3:PutObject",
      "s3:ListBucket",
      "s3:GetObject",
      "s3:GetObjectAcl",
      "s3:GetObjectTagging"
    ]
    resources = [
      "$${bucket_arn}",
      "$${bucket_arn}/*"
    ]
  }

}





resource "kubernetes_secret" "s3_advantis_bucket-secret" {
  metadata {
    name      = "s3-advantis-bucket-output"
    namespace = var.namespace
  }

  data = {
    bucket_arn  = module.s3_advantis_bucket.bucket_arn
    bucket_name = module.s3_advantis_bucket.bucket_name
  }
}










