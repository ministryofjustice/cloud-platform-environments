module "hmpps-audit-api-irsa" {
  source = "github.com/ministryofjustice/cloud-platform-terraform-irsa?ref=2.1.0"

  eks_cluster_name     = var.eks_cluster_name
  namespace            = var.namespace
  service_account_name = "hmpps-audit-api"
  role_policy_arns = {
    (module.hmpps_audit_queue.sqs_name)                             = module.hmpps_audit_queue.irsa_policy_arn
    (module.hmpps_audit_dead_letter_queue.sqs_name)                 = module.hmpps_audit_dead_letter_queue.irsa_policy_arn
    (module.hmpps_prisoner_audit_queue.sqs_name)                    = module.hmpps_prisoner_audit_queue.irsa_policy_arn
    (module.hmpps_prisoner_audit_dead_letter_queue.sqs_name)        = module.hmpps_prisoner_audit_dead_letter_queue.irsa_policy_arn
    (module.hmpps_audit_users_queue.sqs_name)                       = module.hmpps_audit_users_queue.irsa_policy_arn
    (module.hmpps_audit_users_dead_letter_queue.sqs_name)           = module.hmpps_audit_users_dead_letter_queue.irsa_policy_arn
    s3                                                              = aws_iam_policy.allow-irsa-read-write.arn
    hmpps_prisoner_audit_s3                                         = aws_iam_policy.prisoner_audit_allow-irsa-read-write.arn
  }
  # Tags
  business_unit          = var.business_unit
  application            = var.application
  is_production          = var.is_production
  team_name              = var.team_name
  environment_name       = var.environment-name
  infrastructure_support = var.infrastructure_support
}

resource "aws_iam_policy" "allow-irsa-read-write" {
  name        = "audit-read-write-${var.environment-name}"
  path        = "/cloud-platform/"
  policy      = data.aws_iam_policy_document.service_pod_policy_document.json
  description = "Policy for reading audit json files from audit s3 bucket"
}

data "aws_iam_policy_document" "service_pod_policy_document" {
  statement {
    actions = [
      "athena:StartQueryExecution",
      "athena:GetQueryExecution",
      "athena:GetQueryResults",

      "s3:PutObject",
      "s3:GetBucketLocation",
      "s3:GetObject",
      "s3:DeleteObject", # Temporary for debugging, remove when done
      "s3:ListBucket",

      "glue:GetDatabase",
      "glue:GetTable",
      "glue:GetPartition",
      "glue:GetPartitions", # Temporary for debugging, remove when done
      "glue:BatchCreatePartition",
    ]

    resources = [
      aws_athena_workgroup.queries.arn,
      "arn:aws:athena:eu-west-2:*:queryexecution/*",

      "arn:aws:glue:eu-west-2:*:catalog",
      "arn:aws:glue:eu-west-2:*:database/*", # Temporary
      "arn:aws:glue:eu-west-2:*:table/*/*", # Temporary

      aws_glue_catalog_database.audit_glue_catalog_database.arn,
      aws_glue_catalog_table.audit_event_table.arn,
      module.s3.bucket_arn,
      "${module.s3.bucket_arn}/*",

      module.s3_logging_bucket.bucket_arn,
      "${module.s3_logging_bucket.bucket_arn}/*"
    ]
  }
}

resource "aws_iam_policy" "prisoner_audit_allow-irsa-read-write" {
  name        = "prisoner_audit_read_write-${var.environment-name}"
  path        = "/cloud-platform/"
  policy      = data.aws_iam_policy_document.prisoner_audit_service_pod_policy_document.json
  description = "Policy for reading audit json files from prisoner audit s3 bucket"
}

data "aws_iam_policy_document" "prisoner_audit_service_pod_policy_document" {
  statement {
    actions = [
      "athena:StartQueryExecution",
      "athena:GetQueryExecution",
      "athena:GetQueryResults",

      "s3:PutObject",
      "s3:GetBucketLocation",
      "s3:GetObject",
      "s3:ListBucket",

      "glue:GetDatabase",
      "glue:GetTable",
      "glue:GetPartition",
    ]

    resources = [
      aws_athena_workgroup.queries.arn,
      "arn:aws:athena:eu-west-2:*:queryexecution/*",
      "arn:aws:glue:eu-west-2:*:catalog",
      aws_glue_catalog_database.prisoner_audit_glue_catalog_database.arn,
      aws_glue_catalog_table.prisoner_audit_event_table.arn,
      module.hmpps_prisoner_audit_s3.bucket_arn,
      "${module.hmpps_prisoner_audit_s3.bucket_arn}/*",

      module.hmpps_prisoner_audit_s3_logging.bucket_arn,
      "${module.hmpps_prisoner_audit_s3_logging.bucket_arn}/*"
    ]
  }
}
