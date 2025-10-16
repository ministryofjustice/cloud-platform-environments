/*
 * Make sure that you use the latest version of the module by changing the
 * `ref=` value in the `source` attribute to the latest version listed on the
 * releases page of this repository.
 *
 */
module "s3_bucket" {
  source = "github.com/ministryofjustice/cloud-platform-terraform-s3-bucket?ref=5.3.0"

  team_name              = var.team_name
  business_unit          = var.business_unit
  application            = var.application
  is_production          = var.is_production
  environment_name       = var.environment
  infrastructure_support = var.infrastructure_support
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
   * The following are examples of bucket and user policies. They are treated as
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

  /*
   * OIDC for GitHub Actions
   * This allows GitHub Actions to access the S3 bucket using OIDC.
   *
   *
  oidc_providers = ["github"]
  github_repositories = ["my-moj-repo"]
  github_environments = ["dev"]   # If you're using GH Actions environments

*/

  lifecycle_rule = [
    {
      id      = "Retire Processed after 1 days"
      enabled = true
      prefix  = "processed/"

      expiration = [
        {
          days = 1
        }
      ]

      noncurrent_version_expiration = [
        {
          days = 7
        },
      ]

    },
    {
      id      = "Retire Errored after 30 days"
      enabled = true
      prefix  = "errored/"

      expiration = [
        {
          days = 30
        }
      ]

      noncurrent_version_expiration = [
        {
          days = 7
        },
      ]

    }
  ]
}


# Build the policy JSON using the module outputs (no feedback loop)
data "aws_iam_policy_document" "ap_ingestion" {
  statement {
    sid    = "AllowAnalyticalPlatformIngestionService"
    effect = "Allow"

    principals {
      type        = "AWS"
      identifiers = ["arn:aws:iam::730335344807:role/transfer"]
    }

    actions = [
      "s3:GetObject",
      "s3:GetObjectAcl",
      "s3:PutObject",
      "s3:PutObjectAcl",
      "s3:PutObjectTagging",
      "s3:DeleteObject",
    ]

    resources = ["${module.s3_bucket.bucket_arn}/*"]
  }


  statement {
    sid     = "AllowListBucketForAPIngestion"
    effect  = "Allow"

    principals {
      type        = "AWS"
      identifiers = ["arn:aws:iam::730335344807:role/transfer"]
    }

    actions   = ["s3:ListBucket"]
    resources = [module.s3_bucket.bucket_arn]
  }
}

# Attach the policy to the bucket as its own resource
resource "aws_s3_bucket_policy" "ap_ingestion" {
  bucket = module.s3_bucket.bucket_name
  policy = data.aws_iam_policy_document.ap_ingestion.json
}



resource "kubernetes_secret" "s3_bucket" {
  metadata {
    name      = "s3-bucket-output"
    namespace = var.namespace
  }

  data = {
    bucket_arn  = module.s3_bucket.bucket_arn
    bucket_name = module.s3_bucket.bucket_name
  }
}
