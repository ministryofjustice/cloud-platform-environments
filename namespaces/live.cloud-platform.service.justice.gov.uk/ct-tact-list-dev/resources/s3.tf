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

  /*

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
 * Allow the data engineering exporter to push objects to this bucket.
 * https://github.com/moj-analytical-services/data-engineering-exports/pull/44
 *
*/
  bucket_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Principal": {
        "AWS": "arn:aws:iam::593291632749:role/service-role/export_counter_terrorism_exports-move"
      },
      "Action": [
        "s3:PutObject"
      ],
      "Resource": [
        "$${bucket_arn}/*"
      ]
    }
  ]
}
EOF
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
