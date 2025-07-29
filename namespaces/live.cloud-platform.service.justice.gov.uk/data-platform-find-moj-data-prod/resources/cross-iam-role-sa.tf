module "quicksight_irsa" {
    source = "github.com/ministryofjustice/cloud-platform-terraform-irsa?ref=2.1.0"
    eks_cluster_name      = var.eks_cluster_name
    namespace             = var.namespace
    service_account_name  = "find-moj-data-quicksight"
    role_policy_arns = {
        quicksight = aws_iam_policy.find_moj_data_prod_quicksight.arn
    }

    # Tags 
    business_unit          = var.business_unit
    application            = var.application
    is_production          = false
    environment_name       = var.environment
    team_name                  = var.team_name
    infrastructure_support = "findmojdata@justice.gov.uk"
}
data "aws_iam_policy_document" "find_moj_data_prod_quicksight" {
    # Provide list of permissions and target AWS account resources to allow access to
    statement {
        effect = "Allow"
        actions = [
            "sts:TagSession",
            "sts:AssumeRole"
        ]
        resources = [
            "arn:aws:iam::992382429243:role/find-moj-data-quicksight"
        ]
    }
}
resource "aws_iam_policy" "find_moj_data_prod_quicksight" {
    name   = "find-moj-data-prod-quicksight"
    policy = data.aws_iam_policy_document.find_moj_data_prod_quicksight.json

    tags = {
        business-unit          = var.business_unit
        application            = var.application
        is-production          = false
        environment-name       = var.environment
        owner                  = var.team_name
        infrastructure-support = "findmojdata@justice.gov.uk"
    }
}
resource "kubernetes_secret" "irsa" {
    metadata {
    name      = "fmd-quicksight-irsa-output"
    namespace = var.namespace
    }
    data = {
        role           = module.quicksight_irsa.role_name
        rolearn        = module.quicksight_irsa.role_arn
        serviceaccount = module.quicksight_irsa.service_account.name
    }
}
