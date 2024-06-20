resource "aws_iam_user" "ims_s3_user" {
  name = "manage-intelligence-dev-s3-user"
  path = "/system/manage-intelligence-dev-users/"
}

resource "aws_iam_access_key" "key_2024" {
  user = aws_iam_user.ims_s3_user.name
}

data "aws_iam_policy_document" "ims_user_s3_policy" {
  statement {
    actions = ["s3:PutObject", "s3:ListBucket", "s3:GetObject", "s3:DeleteObject"]

    resources = [
      module.ims_images_storage_bucket.bucket_arn,
      "${module.ims_images_storage_bucket.bucket_arn}/*",
      module.ims_attachments_storage_bucket.bucket_arn,
      "${module.ims_attachments_storage_bucket.bucket_arn}/*"
    ]
  }

  statement {
    actions = [
				"kendra:GetQuerySuggestions",
				"kendra:AssociateEntitiesToExperience",
				"kendra:DeleteAccessControlConfiguration",
				"kendra:CreateExperience",
				"kendra:ListExperiences",
				"kendra:DescribeQuerySuggestionsConfig",
				"kendra:CreateThesaurus",
				"kendra:BatchDeleteFeaturedResultsSet",
				"kendra:UpdateThesaurus",
				"kendra:UpdateQuerySuggestionsBlockList",
				"kendra:TagResource",
				"kendra:ListDataSources",
				"kendra:ListTagsForResource",
				"kendra:SubmitFeedback",
				"kendra:DeleteFaq",
				"kendra:ListGroupsOlderThanOrderingId",
				"kendra:DescribeFaq",
				"kendra:DisassociateEntitiesFromExperience",
				"kendra:ListExperienceEntities",
				"kendra:DescribeExperience",
				"kendra:DeleteThesaurus",
				"kendra:ListAccessControlConfigurations",
				"kendra:DescribePrincipalMapping",
				"kendra:UpdateExperience",
				"kendra:GetSnapshots",
				"kendra:DisassociatePersonasFromEntities",
				"kendra:UpdateFeaturedResultsSet",
				"kendra:DescribeFeaturedResultsSet",
				"kendra:ListThesauri",
				"kendra:DescribeDataSource",
				"kendra:DescribeThesaurus",
				"kendra:Query",
				"kendra:StopDataSourceSyncJob",
				"kendra:BatchPutDocument",
				"kendra:Retrieve",
				"kendra:CreateQuerySuggestionsBlockList",
				"kendra:ClearQuerySuggestions",
				"kendra:ListFaqs",
				"kendra:AssociatePersonasToEntities",
				"kendra:DescribeQuerySuggestionsBlockList",
				"kendra:StartDataSourceSyncJob",
				"kendra:ListEntityPersonas",
				"kendra:PutPrincipalMapping",
				"kendra:DescribeAccessControlConfiguration",
				"kendra:ListQuerySuggestionsBlockLists",
				"kendra:CreateFaq",
				"kendra:UpdateQuerySuggestionsConfig",
				"kendra:CreateFeaturedResultsSet",
				"kendra:DeleteQuerySuggestionsBlockList",
				"kendra:DescribeIndex",
				"kendra:DeleteExperience",
				"kendra:ListFeaturedResultsSets",
				"kendra:UntagResource",
				"kendra:ListDataSourceSyncJobs",
				"kendra:DeletePrincipalMapping",
				"kendra:BatchGetDocumentStatus",
				"kendra:UpdateAccessControlConfiguration",
				"kendra:CreateAccessControlConfiguration",
				"kendra:BatchDeleteDocument"
    ]

    resources = [
      resource.aws_kendra_index.main
    ]
  }

  statement {
    effect = "Deny"

    actions = ["s3:*"]

    resources = [
      module.ims_images_storage_bucket.bucket_arn,
      "${module.ims_images_storage_bucket.bucket_arn}/*",
      module.ims_attachments_storage_bucket.bucket_arn,
      "${module.ims_attachments_storage_bucket.bucket_arn}/*"
    ]

    condition {
      test     = "Bool"
      variable = "aws:SecureTransport"
      values   = ["false"]
    }
  }
}

resource "aws_iam_user_policy" "ims_user_s3_policy" {
  name   = "manage-intelligence-user-s3-policy-dev"
  policy = data.aws_iam_policy_document.ims_user_s3_policy.json
  user   = aws_iam_user.ims_s3_user.name
}

resource "kubernetes_secret" "ims_s3_kendra_user" {
  metadata {
    name      = "ims-s3-kendra-user-dev"
    namespace = var.namespace
  }

  data = {
    arn               = aws_iam_user.ims_s3_user.arn
    access_key_id     = aws_iam_access_key.key_2024.id
    secret_access_key = aws_iam_access_key.key_2024.secret
  }
}