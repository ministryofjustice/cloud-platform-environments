/*
 * Make sure that you use the latest version of the module by changing the
 * `ref=` value in the `source` attribute to the latest version listed on the
 * releases page of this repository.
 *
 */
module "submit_information_report_dynamodb" {
  source = "github.com/ministryofjustice/cloud-platform-terraform-dynamodb-cluster?ref=3.1.3"

  team_name              = "digital-prison-services"
  application            = "HMPPS Submit Information Report"
  business-unit          = var.business-unit
  environment-name       = var.environment-name
  infrastructure-support = var.infrastructure-support
  is-production          = "false"
  namespace              = var.namespace

  hash_key = "id"
}

resource "kubernetes_secret" "submit_information_report_dynamodb" {
  metadata {
    name      = "submit-information-report-dynamodb-output"
    namespace = var.namespace
  }

  data = {
    table_name        = module.submit_information_report_dynamodb.table_name
    table_arn         = module.submit_information_report_dynamodb.table_arn
    access_key_id     = module.submit_information_report_dynamodb.access_key_id
    secret_access_key = module.submit_information_report_dynamodb.secret_access_key
  }
}

module "submit_information_report_reports_dynamodb" {
  source = "github.com/ministryofjustice/cloud-platform-terraform-dynamodb-cluster?ref=3.1.3"

  team_name              = "digital-prison-services"
  application            = "HMPPS Submit Information Report"
  business-unit          = var.business-unit
  environment-name       = var.environment-name
  infrastructure-support = var.infrastructure-support
  is-production          = "false"
  namespace              = var.namespace

  hash_key = "email"
}

resource "kubernetes_secret" "submit_information_report_reports_dynamodb" {
  metadata {
    name      = "submit-information-report-reports-dynamodb-output"
    namespace = var.namespace
  }

  data = {
    table_name        = module.submit_information_report_reports_dynamodb.table_name
    table_arn         = module.submit_information_report_reports_dynamodb.table_arn
    access_key_id     = module.submit_information_report_reports_dynamodb.access_key_id
    secret_access_key = module.submit_information_report_reports_dynamodb.secret_access_key
  }
}
