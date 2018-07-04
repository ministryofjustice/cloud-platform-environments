
module "example_team_s3" {
  source = "github.com/ministryofjustice/cloud-platform-terraform-s3-bucket?ref=master"

  team_name              = "cloudplatform"
  bucket_identifier      = "platform-dev"
  acl                    = "private"
  versioning             = true
  business-unit          = "mojdigital"
  application            = "pipeline-example-app"
  is-production          = "false"
  environment-name       = "development"
  infrastructure-support = "platform@digtal.justice.gov.uk"
}
