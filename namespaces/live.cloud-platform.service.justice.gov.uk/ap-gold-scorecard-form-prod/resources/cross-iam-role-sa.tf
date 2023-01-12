module "irsa" {
  eks_cluster_name = var.eks_cluster_name
  source           = "github.com/ministryofjustice/cloud-platform-terraform-irsa?ref=1.0.6"
  namespace        = "ap-gold-scorecard-form-prod"
  role_policy_arns = [aws_iam_policy.ap-gold-scorecard-form-prod.arn]
}

data "aws_iam_policy_document" "ap-gold-scorecard-form-prod" {
  statement {
    sid = "listbucket"
    actions = [
      "s3:ListBucket",
      "s3:GetBucketLocation",
    ]
    resources = [
      "arn:aws:s3:::alpha-app-scorecard-form",
      "arn:aws:s3:::alpha-athena-query-dump",
      "arn:aws:s3:::mojap-athena-query-dump",
    ]
  }

  statement {
    sid = "readwritebucket"
    actions = [
      "s3:GetObject",
      "s3:GetObjectAcl",
      "s3:GetObjectVersion",
      "s3:DeleteObject",
      "s3:DeleteObjectVersion",
      "s3:PutObject",
      "s3:PutObjectAcl",
      "s3:RestoreObject",
    ]
    resources = [
      "arn:aws:s3:::alpha-app-scorecard-form/*",
      "arn:aws:s3:::alpha-athena-query-dump/$${aws:userid}/*",
      "arn:aws:s3:::mojap-athena-query-dump/$${aws:userid}/*",
    ]
  }

  statement {
    sid = "readGlue"
    actions = [
      "glue:GetDatabase",
      "glue:GetDatabases",
      "glue:GetTable",
      "glue:GetTables",
      "glue:GetPartition",
      "glue:GetPartitions",
      "glue:BatchGetPartition",
      "glue:GetCatalogImportStatus",
      "glue:GetUserDefinedFunction",
      "glue:GetUserDefinedFunctions",
    ]
    resources = [
      "arn:aws:glue:eu-west-1:593291632749:catalog",
      "arn:aws:glue:eu-west-1:593291632749:database/default",
      "arn:aws:glue:eu-west-1:593291632749:database/contracts",
      "arn:aws:glue:eu-west-1:593291632749:database/contracts_*",
      "arn:aws:glue:eu-west-1:593291632749:table/contracts/*",
      "arn:aws:glue:eu-west-1:593291632749:table/contracts_*/scorecard",
      "arn:aws:glue:eu-west-1:593291632749:table/contracts_*/vfm",
      "arn:aws:glue:eu-west-1:593291632749:userDefinedFunction/*",
    ]
  }

  statement {
    sid = "readAthena"
    actions = [
      "athena:BatchGetNamedQuery",
      "athena:BatchGetQueryExecution",
      "athena:GetNamedQuery",
      "athena:GetQueryExecution",
      "athena:GetQueryResults",
      "athena:GetQueryResultsStream",
      "athena:GetWorkGroup",
      "athena:ListNamedQueries",
      "athena:ListWorkGroups",
      "athena:StartQueryExecution",
      "athena:StopQueryExecution",
      "athena:CancelQueryExecution",
      "athena:GetCatalogs",
      "athena:GetExecutionEngine",
      "athena:GetExecutionEngines",
      "athena:GetNamespace",
      "athena:GetNamespaces",
      "athena:GetTable",
      "athena:GetTables",
      "athena:RunQuery",
    ]
    resources = [
      "arn:aws:athena:eu-west-2:754256621582:workgroup/primary",
    ]
  }
}

resource "aws_iam_policy" "ap-gold-scorecard-form-prod" {
  name   = "ap-gold-scorecard-form-prod"
  policy = data.aws_iam_policy_document.ap-gold-scorecard-form-prod.json

  tags = {
    business-unit          = "Cloud Platform"
    application            = "Gold Scorecard Form"
    is-production          = "true"
    environment-name       = "Production"
    owner                  = "cloud-platform"
    infrastructure-support = "platforms@digital.justice.gov.uk"
  }
}

resource "kubernetes_secret" "irsa" {
  metadata {
    name      = "irsa-output"
    namespace = "ap-gold-scorecard-form-prod"
  }
  data = {
    role           = module.irsa.aws_iam_role_arn
    serviceaccount = module.irsa.service_account_name.name
  }
}

# IAM user so athena can access S3 buckets in the analytical platform data aws account
resource "aws_iam_user" "ap-gold-scorecard-form-prod" {
  name = "ap-gold-scorecard-form-prod"

  tags = {
    business-unit          = "Cloud Platform"
    application            = "Gold Scorecard Form"
    is-production          = "true"
    environment-name       = "Production"
    owner                  = "cloud-platform"
    infrastructure-support = "platforms@digital.justice.gov.uk"
    usage-scope            = "athena"
  }
}
