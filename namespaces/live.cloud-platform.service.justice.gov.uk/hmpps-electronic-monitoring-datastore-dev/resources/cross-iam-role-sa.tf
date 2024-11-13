
    module "irsa" {
      source = "github.com/ministryofjustice/cloud-platform-terraform-irsa?ref=2.0.0"
      eks_cluster_name      = var.eks_cluster_name
      namespace             = var.namespace
      service_account_name  = "${var.namespace}-service-account"
      role_policy_arns = [aws_iam_policy.em_datastore_api_dev_athena_general.arn]
    }

    data "aws_iam_policy_document" "document" {
      # Provide list of permissions and target AWS account resources to allow access to
      statement {
        actions = []
        # actions = [
        #   "athena:CancelQueryExecution",
        #   "athena:GetQueryExecution",
        #   "athena:GetQueryResults",
        #   "athena:GetWorkGroup",
        #   "athena:StartQueryExecution",
        #   "athena:StopQueryExecution",
        #   "s3:GetObject",
        #   "s3:PutObject",
        #   "s3:ListBucket",
        #   "s3:ListAllMyBuckets",
        #   "s3:GetBucketLocation",
        #   "s3:ListBucketMultipartUploads",
        #   "s3:ListMultipartUploadParts",
        #   "s3:AbortMultipartUpload",
        #   "s3:CreateBucket",
        #   "glue:GetDatabase",
        #   "glue:GetTable",
        #   "glue:GetTables",
        #   "glue:UpdateTable",
        #   "glue:DeleteTable",
        #   "glue:GetPartitions",
        #   "glue:GetPartition",
        #   "glue:BatchCreatePartition",
        #   "glue:GetDatabases",
        #   "glue:CreateTable",
        #   "glue:CreateDatabase",
        #   "glue:DeleteTable",
        # ]
        resources = []
        # resources = [
        #   "arn:aws:athena:eu-west-2:800964199911:workgroup/*",
        # ]
      }
    }
    resource "aws_iam_policy" "em_datastore_api_dev_athena_general" {
      name   = "em-datastore-api-athena-general"
      policy = data.aws_iam_policy_document.document.json

      tags = {
        business-unit          = var.business_unit
        application            = var.application
        is-production          = var.is_production
        environment-name       = var.environment
        owner                  = var.team_name
        infrastructure-support = var.infrastructure_support
      }
    }
    resource "kubernetes_secret" "irsa" {
      metadata {
        name      = "irsa-output"
        namespace = var.namespace
      }
      data = {
        role = module.irsa.aws_iam_role_name
        serviceaccount = module.irsa.service_account_name.name
      }
    }