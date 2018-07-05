provider "aws" {
  region   = "eu-west-1"
}

module "example_team_s3" {
  source = "github.com/ministryofjustice/cloud-platform-terraform-s3-bucket?ref=master"

  team_name              = "cloudplatform"
  bucket_identifier      = "platform-dev"
  acl                    = "private"
  versioning             = false
  business-unit          = "mojdigital"
  application            = "pipeline-example-app"
  is-production          = "true"
  environment-name       = "development"
  infrastructure-support = "platform@digtal.justice.gov.uk"
}
