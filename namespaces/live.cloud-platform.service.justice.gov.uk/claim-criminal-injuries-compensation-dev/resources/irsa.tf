module "irsa-appservice" {
  source = "github.com/ministryofjustice/cloud-platform-terraform-irsa?ref=2.0.0"

  # EKS configuration
  eks_cluster_name = var.eks_cluster_name

  # IRSA configuration
  service_account_name = "irsaappservice"
  namespace            = var.namespace # this is also used as a tag

  # Attach the approprate policies using a key => value map
  # If you're using Cloud Platform provided modules (e.g. SNS, S3), these
  # provide an output called `irsa_policy_arn` that can be used.
  role_policy_arns = {

    sqsappqueue    = module.claim-criminal-injuries-application-queue.irsa_policy_arn
    sqstempusqueue = module.claim-criminal-injuries-tempus-queue.irsa_policy_arn
    policy         = aws_iam_policy.app_service_S3_access_policy.arn

  }

  # Tags
  business_unit          = var.business_unit
  application            = var.application
  is_production          = var.is_production
  team_name              = var.team_name
  environment_name       = var.environment-name
  infrastructure_support = var.infrastructure_support
}

resource "kubernetes_secret" "irsaappservice" {
  metadata {
    name      = "irsa-appserviceoutput"
    namespace = var.namespace
  }
  data = {
    role           = module.irsa-appservice.role_name
    serviceaccount = module.irsa-appservice.service_account.name
    rolearn        = module.irsa-appservice.role_arn
  }
}

module "irsa-dcs" {
  source = "github.com/ministryofjustice/cloud-platform-terraform-irsa?ref=2.0.0"

  # EKS configuration
  eks_cluster_name = var.eks_cluster_name

  # IRSA configuration
  service_account_name = "irsadcs"
  namespace            = var.namespace # this is also used as a tag

  # Attach the approprate policies using a key => value map
  # If you're using Cloud Platform provided modules (e.g. SNS, S3), these
  # provide an output called `irsa_policy_arn` that can be used.
  role_policy_arns = {

    sqsnotifyqueue = module.claim-criminal-injuries-notify-queue.irsa_policy_arn
    sqsappqueue    = module.claim-criminal-injuries-application-queue.irsa_policy_arn
    policy         = aws_iam_policy.dcs_S3_access_policy.arn

  }

  # Tags
  business_unit          = var.business_unit
  application            = var.application
  is_production          = var.is_production
  team_name              = var.team_name
  environment_name       = var.environment-name
  infrastructure_support = var.infrastructure_support
}

resource "kubernetes_secret" "irsadcs" {
  metadata {
    name      = "irsa-dcsoutput"
    namespace = var.namespace
  }
  data = {
    role           = module.irsa-dcs.role_name
    serviceaccount = module.irsa-dcs.service_account.name
    rolearn        = module.irsa-dcs.role_arn
  }
}

module "irsa-notifyservice" {
  source = "github.com/ministryofjustice/cloud-platform-terraform-irsa?ref=2.0.0"

  # EKS configuration
  eks_cluster_name = var.eks_cluster_name

  # IRSA configuration
  service_account_name = "irsanotifyservice"
  namespace            = var.namespace # this is also used as a tag

  # Attach the approprate policies using a key => value map
  # If you're using Cloud Platform provided modules (e.g. SNS, S3), these
  # provide an output called `irsa_policy_arn` that can be used.
  role_policy_arns = {

    sqs = module.claim-criminal-injuries-notify-queue.irsa_policy_arn

  }

  # Tags
  business_unit          = var.business_unit
  application            = var.application
  is_production          = var.is_production
  team_name              = var.team_name
  environment_name       = var.environment-name
  infrastructure_support = var.infrastructure_support
}

resource "kubernetes_secret" "irsanotify" {
  metadata {
    name      = "irsa-notifyoutput"
    namespace = var.namespace
  }
  data = {
    role           = module.irsa-notifyservice.role_name
    serviceaccount = module.irsa-notifyservice.service_account.name
    rolearn        = module.irsa-notifyservice.role_arn
  }
}

module "irsa-rds" {
  source = "github.com/ministryofjustice/cloud-platform-terraform-irsa?ref=2.0.0"

  # EKS configuration
  eks_cluster_name = var.eks_cluster_name

  # IRSA configuration
  service_account_name = "irsards"
  namespace            = var.namespace # this is also used as a tag

  # Attach the approprate policies using a key => value map
  # If you're using Cloud Platform provided modules (e.g. SNS, S3), these
  # provide an output called `irsa_policy_arn` that can be used.
  role_policy_arns = {

    rds = module.rds.irsa_policy_arn

  }

  # Tags
  business_unit          = var.business_unit
  application            = var.application
  is_production          = var.is_production
  team_name              = var.team_name
  environment_name       = var.environment-name
  infrastructure_support = var.infrastructure_support
}

resource "kubernetes_secret" "irsards" {
  metadata {
    name      = "irsa-rdsoutput"
    namespace = var.namespace
  }
  data = {
    role           = module.irsa-rds.role_name
    serviceaccount = module.irsa-rds.service_account.name
    rolearn        = module.irsa-rds.role_arn
  }
}