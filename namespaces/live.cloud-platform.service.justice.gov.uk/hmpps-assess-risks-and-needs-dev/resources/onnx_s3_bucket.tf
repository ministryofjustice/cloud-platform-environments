/*
 * Make sure that you use the latest version of the module by changing the
 * `ref=` value in the `source` attribute to the latest version listed on the
 * releases page of this repository.
 *
 * An S3 bucket that the data science team can use to place updated ONNX files into
 * for use by assess risks and needs
 */
module "hmpps_assess_risks_and_needs_onnx_s3_bucket" {

  source                 = "github.com/ministryofjustice/cloud-platform-terraform-s3-bucket?ref=4.7.3"
  team_name              = var.team_name
  business-unit          = var.business_unit
  application            = var.application
  is-production          = var.is_production
  environment-name       = var.environment_name
  infrastructure-support = var.infrastructure_support
  namespace              = var.namespace

  providers = {
    aws = aws.london
  }

  bucket_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Principal": {
        "AWS": "arn:aws:iam::593291632749:role/service-role/analytical-platform-hub-export"
      },
      "Action": [
        "s3:PutObject",
        "s3:ListObjects",
        "s3:ListObjectsV2"
      ],
      "Resource": [
        "$${bucket_arn}/*"
      ]
    }
  ]
}
EOF
}


resource "kubernetes_secret" "hmpps_assess_risks_and_needs_onnx_s3_bucket" {
  metadata {
    name      = "hmpps-assess-risks-and-needs-onnx-s3-bucket"
    namespace = var.namespace
  }

  data = {
    access_key_id     = module.hmpps_assess_risks_and_needs_onnx_s3_bucket.access_key_id
    secret_access_key = module.hmpps_assess_risks_and_needs_onnx_s3_bucket.secret_access_key
    bucket_arn        = module.hmpps_assess_risks_and_needs_onnx_s3_bucket.bucket_arn
    bucket_name       = module.hmpps_assess_risks_and_needs_onnx_s3_bucket.bucket_name
  }
}
