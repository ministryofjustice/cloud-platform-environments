module "analytical_platform_assumable_role" {
  source  = "terraform-aws-modules/iam/aws//modules/iam-assumable-role"
  version = "5.52.2"
  create_role  = true
  trusted_role_arns = [
  ]
  role_name                     = "gpc-anomalies-role-assumable-from-ap"
  role_requires_mfa = false
  custom_role_policy_arns = [
    module.iam_policy.arn # <--- this is the policy you pass to the IRSA role module
  ]
}
