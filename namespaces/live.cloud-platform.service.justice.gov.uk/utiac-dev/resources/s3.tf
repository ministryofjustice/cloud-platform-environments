module "s3_bucket" {
  source                        = "github.com/ministryofjustice/cloud-platform-terraform-s3-bucket?ref=5.1.0"
  
  team_name                     = var.team_name
  business_unit                 = var.business_unit
  application                   = var.application
  is_production                 = var.is_production
  environment_name              = var.environment
  infrastructure_support        = var.infrastructure_support
  namespace                     = var.namespace
  versioning                    = true
  enable_allow_block_pub_access = false

  bucket_policy = <<EOF
    {
      "Version": "2012-10-17",
      "Statement": [
        {
          "Effect": "Allow",
          "Principal": {
            "AWS": "*"
          },
          "Action": [
            "s3:*"
          ],
          "Resource": [
            "$${bucket_arn}/*"
          ]
        }
      ]
    }
    EOF
}

data "aws_iam_policy_document" "s3_access_policy" {
  statement {
    sid = "AllowUserToReadAndWriteS3"
    actions = [
      "s3:*"
    ]

    resources = [
      module.s3_bucket.bucket_arn,
      "${module.s3_bucket.bucket_arn}/*"
    ]
  }
}

resource "aws_iam_user" "s3_user" {
  name = "s3-user-${var.environment}"
  path = "/system/s3-user/"
}

resource "aws_iam_access_key" "s3_user" {
  user = aws_iam_user.s3_user.name
}

resource "aws_iam_user_policy" "s3_user_policy" {
  name   = "s3-read-write-policy"
  policy = data.aws_iam_policy_document.s3_access_policy.json
  user   = aws_iam_user.s3_user.name
}


resource "kubernetes_secret" "s3_bucket" {
  metadata {
    name      = "s3-bucket-output"
    namespace = var.namespace
  }

  data = {
    bucket_arn                    = module.s3_bucket.bucket_arn
    bucket_name                   = module.s3_bucket.bucket_name
    s3_access_user_arn   = aws_iam_user.s3_user.arn
    s3_access_key_id     = aws_iam_access_key.s3_user.id
    s3_secret_access_key = aws_iam_access_key.s3_user.secret
  }
}
