/*
 * Make sure that you use the latest version of the module by changing the
 * `ref=` value in the `source` attribute to the latest version listed on the
 * releases page of this repository.
 *
 */
module "s3_bucket" {

  source                 = "github.com/ministryofjustice/cloud-platform-terraform-s3-bucket?ref=4.7.1"
  team_name              = var.team_name
  business-unit          = var.business_unit
  application            = var.application
  is-production          = var.is_production
  environment-name       = var.environment
  infrastructure-support = var.infrastructure_support
  namespace              = var.namespace

  /*

  * Public Buckets: It is strongly advised to keep buckets 'private' and only make public where necessary.
                    By default buckets are private, however to create a 'public' bucket add the following two variables when calling the module:

                    acl                           = "public-read"
                    enable_allow_block_pub_access = false

                    For more information granting public access to S3 buckets, please see AWS documentation:
                    https://docs.aws.amazon.com/AmazonS3/latest/dev/access-control-block-public-access.html

  * Converting existing private bucket to public: If amending an existing private bucket that was created using version 4.3 or above then you will need to raise two PRs:

                    (1) First PR to add the var: enable_allow_block_pub_access = false
                    (2) Second PR to add the var: acl = "public-read"

  * Versioning: By default this is set to false. When set to true multiple versions of an object can be stored
                For more details on versioning please visit: https://docs.aws.amazon.com/AmazonS3/latest/dev/Versioning.html

  versioning             = true

  * Logging: By default set to false. When you enable logging, Amazon S3 delivers access logs for a source bucket to a target bucket that you choose.
             The target bucket must be in the same AWS Region as the source bucket and must not have a default retention period configuration.
             For more details on logging please vist: https://docs.aws.amazon.com/AmazonS3/latest/user-guide/server-access-logging.html

  logging_enabled        = true
  log_target_bucket      = "<TARGET_BUCKET_NAME>"

  # NOTE: Important note that the target bucket for logging must have it's 'acl' property set to 'log-delivery-write'.
          To apply this to an existing target bucket simply add the followng variable to its terraform module
          acl = "log-delivery-write"

  log_path               = "<LOG_PATH>" e.g log/

*/

  providers = {
    # Can be either "aws.london" or "aws.ireland"
    aws = aws.london
  }
    /*
   * The following example can be used if you need to define CORS rules for your s3 bucket.
   *  Follow the guidance here "https://www.terraform.io/docs/providers/aws/r/s3_bucket.html#using-cors"
   *

  cors_rule =[
    {
      allowed_headers = ["*"]
      allowed_methods = ["GET"]
      allowed_origins = ["https://s3-website-test.hashicorp.com"]
      expose_headers  = ["ETag"]
      max_age_seconds = 3000
    },
    {
      allowed_headers = ["*"]
      allowed_methods = ["PUT"]
      allowed_origins = ["https://s3-website-test.hashicorp.com"]
      expose_headers  = [""]
      max_age_seconds = 3000
    },
  ]


  /*
   * The following example can be used if you need to set a lifecycle for your s3.
   *  Follow the guidance here "https://www.terraform.io/docs/providers/aws/r/s3_bucket.html#using-object-lifecycle"
   *  "https://docs.aws.amazon.com/AmazonS3/latest/dev/object-lifecycle-mgmt.html"
   *
  lifecycle_rule = [
    {
      enabled = true
      id      = "retire exports after 7 days"
      prefix  = "surveys/export"

      noncurrent_version_expiration = [
        {
          days = 7
        },
      ]

      expiration = [
        {
          days = 7
        },
      ]
    },
    {
      enabled = true
      id      = "retire imports after 10 days"
      prefix  = "surveys/imports"

      expiration = [
        {
          days = 7
        },
      ]
    },
  ]

  */

    /*
   * The following are exampls of bucket and user policies. They are treated as
   * templates. Currently, the only available variable is `$${bucket_arn}`.
   *
   */

    /*
 * Allow a user (foobar) from another account (012345678901) to get objects from
 * this bucket.
 *

   bucket_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Principal": {
        "AWS": "arn:aws:iam::012345678901:user/foobar"
      },
      "Action": [
        "s3:GetObject"
      ],
      "Resource": [
        "$${bucket_arn}/*"
      ]
    }
  ]
}
EOF

*/

  user_policy = "${data.aws_iam_policy_document.bucket_user_policy.json}"

}

data "aws_iam_policy_document" "bucket_user_policy" {
  statement {
    effect = "Allow"

    actions = [
      "s3:GetBucketLocation",
      "s3:ListBucket",
      "s3:ListBucketMultipartUploads"
    ]

    resources = ["${module.s3_bucket.bucket_arn}"]

  }
  statement {
    effect = "Allow"

    actions = [
      "s3:GetObject",
      "s3:AbortMultipartUpload",
      "s3:ListMultipartUploadParts",
      "s3:PutObjectTagging",
      "s3:GetObjectTagging",
      "s3:PutObject"
    ]

    resources = ["${module.s3_bucket.bucket_arn}/*"]

  }

  statement {
    effect = "Allow"

    actions = [
      "datasync:CreateLocationS3"
    ]

    resources = ["arn:aws:datasync:eu-west-2:${data.aws_caller_identity.current.account_id}:location/*"]

  }
}


resource "kubernetes_secret" "s3_bucket" {
  metadata {
    name      = "s3-bucket-output"
    namespace = var.namespace
  }

  data = {
    access_key_id     = module.s3_bucket.access_key_id
    secret_access_key = module.s3_bucket.secret_access_key
    bucket_arn        = module.s3_bucket.bucket_arn
    bucket_name       = module.s3_bucket.bucket_name
  }
}
