module "s3_bucket" {

  source                 = "github.com/ministryofjustice/cloud-platform-terraform-s3-bucket?ref=5.1.0"
  team_name              = var.team_name
  business_unit          = var.business_unit
  application            = var.application
  is_production          = var.is_production
  environment_name       = var.environment
  infrastructure_support = var.infrastructure_support
  namespace              = var.namespace
  versioning             = true

  providers = {
    aws = aws.ireland
  }

  bucket_policy = <<EOF
  {
    "Version": "2012-10-17",
    "Statement": [
      {
        "Sid": "AllowBucketAccess",
        "Effect": "Allow",
        "Principal": {
          "AWS": "${aws_iam_role.api_gateway_role.arn}"
        },
        "Action": "s3:PutObject",
        "Resource": [
          "$${bucket_arn}",
          "$${bucket_arn}/*"
        ]
      }
    ]
  }
  EOF

}

data "aws_iam_policy_document" "cgi_s3_access_policy" {

  statement {
    sid = "AllowCgiUserToReadAndWriteS3"
    actions = [
      "s3:GetObject*",
      "s3:DeleteObject*",
      "s3:ListBucket",
      "s3:GetBucketLocation"
    ]

    resources = [
      module.s3_bucket.bucket_arn,
      "${module.s3_bucket.bucket_arn}/*"
    ]
  }
}

resource "aws_iam_user" "user" {
  name = "cgi-s3-access-user-${var.environment}"
  path = "/system/cgi-s3-access-user/"
}

resource "aws_iam_access_key" "user" {
  user = aws_iam_user.user.name
}

resource "aws_iam_user_policy" "policy" {
  name   = "cgi-s3-read-write-policy"
  policy = data.aws_iam_policy_document.cgi_s3_access_policy.json
  user   = aws_iam_user.user.name
}


resource "kubernetes_secret" "s3_bucket" {
  metadata {
    name      = "s3-bucket-output"
    namespace = var.namespace
  }

  data = {
    bucket_arn               = module.s3_bucket.bucket_arn
    bucket_name              = module.s3_bucket.bucket_name
    cgi_s3_access_user_arn   = aws_iam_user.user.arn
    cgi_s3_access_key_id     = aws_iam_access_key.user.id
    cgi_s3_secret_access_key = aws_iam_access_key.user.secret
  }
}
