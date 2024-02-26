/*
 * Make sure that you use the latest version of the module by changing the
 * `ref=` value in the `source` attribute to the latest version listed on the
 * releases page of this repository.
 *
 */
module "s3_bucket" {

  source                 = "github.com/ministryofjustice/cloud-platform-terraform-s3-bucket?ref=5.1.0"
  team_name              = var.team_name
  business_unit          = var.business_unit
  application            = var.application
  is_production          = var.is_production
  environment_name       = var.environment
  infrastructure_support = var.infrastructure_support
  namespace              = var.namespace

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
            "s3:GetObject",
            "s3:PutObject"
          ],
          "Resource": [
            "$${bucket_arn}/*"
          ]
        }
      ]
    }
  EOF

  providers = {
    aws = aws.london
  }
}

data "aws_iam_policy_document" "external_user_s3_grc_access_policy" {
  statement {
    sid = "AllowExternalUserToReadAndPutObjectsInS3"
    actions = [
      "s3:PutObject",
      "s3:ListBucket",
      "s3:GetObject*",
    ]

    resources = [
      module.s3_bucket.bucket_arn,
      "${module.s3_bucket.bucket_arn}/*"
    ]
  }
}

resource "aws_iam_user" "s3-grc-user" {
  name = "external-s3-access-grc-user-${var.environment}"
  path = "/system/external-s3-access-user/"
}

resource "aws_iam_access_key" "s3-grc-user" {
  user = aws_iam_user.s3-grc-user.name
}

resource "aws_iam_user_policy" "s3-policy" {
  name   = "external-s3-read-write-policy"
  policy = data.aws_iam_policy_document.external_user_s3_grc_access_policy.json
  user   = aws_iam_user.s3-grc-user.name
}

resource "kubernetes_secret" "s3_bucket" {
  metadata {
    name      = "s3-bucket-output"
    namespace = var.namespace
  }

  data = {
    bucket_arn                    = module.s3_bucket.bucket_arn
    bucket_name                   = module.s3_bucket.bucket_name
    external_s3_access_user_arn   = aws_iam_user.s3-grc-user.arn
    external_s3_access_key_id     = aws_iam_access_key.s3-grc-user.id
    external_s3_secret_access_key = aws_iam_access_key.s3-grc-user.secret
  }
}