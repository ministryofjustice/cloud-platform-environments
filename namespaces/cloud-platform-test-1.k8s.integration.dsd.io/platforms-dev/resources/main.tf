provider "aws" {
  region   = "eu-west-1"
}

module "example_team_s3" {
  source = "github.com/ministryofjustice/cloud-platform-terraform-s3-bucket?ref=master"

  team_name              = "platform"
  bucket_identifier      = "bucket"
  acl                    = "private"
  versioning             = false
  business-unit          = "mojdigital"
  application            = "pipeline-example"
  is-production          = "false"
  environment-name       = "development"
  infrastructure-support = "platform@digtal.justice.gov.uk"
}
