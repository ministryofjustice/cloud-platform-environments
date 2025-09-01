# Cloud Platform Terraform Module - SQS With Namespace to Namespace Communication and Permissions

**NOTE**: This module currently **DOES NOT** support the use of an encrypted SQS queue.

## Usage (Producer Namespace)

In order to configure, provide a list of consumer namespaces based on their `var.namespace` value. I.E. the value that is applied to the `namespace` tag on the consuming applications' IRSA service accounts.

```bash
#--Consumed by the sqs_queue module
module "irsa" {
  source               = "github.com/ministryofjustice/cloud-platform-terraform-irsa?ref=2.1.0"
  eks_cluster_name     = "live"
  service_account_name = "irsa-${var.namespace}"
  namespace            = var.namespace
  role_policy_arns = {
    sqs = module.sqs.irsa_policy_arn
  }
  business_unit          = var.business_unit
  application            = var.application
  is_production          = var.is_production
  team_name              = var.team_name
  environment_name       = var.environment
  infrastructure_support = var.infrastructure_support
}

module "sqs_queue" {
  source                            = "./modules/sqs"
  queue_name                        = "${var.namespace}-sqs-queue"
  sqs_queue_subscriber_namespaces = ["consumer-application-1-dev", "consumer-application-2-dev", "consumer-application-3-dev"]
  business_unit                     = var.business_unit
  application                       = var.application
  is_production                     = var.is_production
  team_name                         = var.team_name
  namespace                         = var.namespace
  environment                       = var.environment
  infrastructure_support            = var.infrastructure_support
}
```

This module will create two SSM Parameters for external consumption (one containing the SQS queue ARN, and one containing the IRSA Policy ARN).

## Usage (Consumer Namespaces)

In order to consume from the SQS queue from another CP namespace:

```bash
data "aws_ssm_parameter" "sqs_queue_arn" {
  name = "/${var.producer_namespace}/sqs-queue-arn"
}

data "aws_ssm_parameter" "sqs_policy_arn" {
  name = "/${var.producer_namespace}/sqs-policy-arn"
}

module "irsa" {
  source = "github.com/ministryofjustice/cloud-platform-terraform-irsa?ref=2.1.0"
  eks_cluster_name = var.eks_cluster_name
  service_account_name = "irsa-sqs-${var.namespace}"
  namespace            = var.namespace
  
  role_policy_arns = {
    sqs = data.aws_ssm_parameter.sqs_policy_arn.value
  }
  business_unit          = var.business_unit
  application            = var.application
  is_production          = var.is_production
  team_name              = var.team_name
  environment_name       = var.environment
  infrastructure_support = var.infrastructure_support
}

resource "kubernetes_secret" "irsa" {
  metadata {
    name      = "${var.namespace}-irsa"
    namespace = var.namespace
  }
  data = {
    role           = module.irsa.role_name
    serviceaccount = module.irsa.service_account.name
    rolearn        = module.irsa.role_arn
  }
}

resource "kubernetes_secret" "sqs_queue_arn" {
  metadata {
    name      = "${var.namespace}-sqs-arn"
    namespace = var.namespace
  }
  data = {
    arn = data.aws_ssm_parameter.sqs_queue_arn.value
  }
}
```

<!-- BEGIN_TF_DOCS -->
## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 1.2.5 |
| <a name="requirement_aws"></a> [aws](#requirement\_aws) | ~> 5.78.0 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_aws"></a> [aws](#provider\_aws) | ~> 5.78.0 |

## Modules

| Name | Source | Version |
|------|--------|---------|
| <a name="module_dlq"></a> [dlq](#module\_dlq) | github.com/ministryofjustice/cloud-platform-terraform-sqs | 5.1.2 |
| <a name="module_queue"></a> [queue](#module\_queue) | github.com/ministryofjustice/cloud-platform-terraform-sqs | 5.1.2 |

## Resources

| Name | Type |
|------|------|
| [aws_sqs_queue_policy.dlq](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/sqs_queue_policy) | resource |
| [aws_sqs_queue_policy.sqs](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/sqs_queue_policy) | resource |
| [aws_ssm_parameter.sqs_irsa_policy_arn](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/ssm_parameter) | resource |
| [aws_ssm_parameter.sqs_queue_arn](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/ssm_parameter) | resource |
| [aws_iam_policy_document.dlq](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/iam_policy_document) | data source |
| [aws_iam_policy_document.queue](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/iam_policy_document) | data source |
| [aws_iam_role.sqs_matching_roles](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/iam_role) | data source |
| [aws_iam_roles.sqs_subscriber_roles](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/iam_roles) | data source |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_application"></a> [application](#input\_application) | n/a | `string` | n/a | yes |
| <a name="input_business_unit"></a> [business\_unit](#input\_business\_unit) | n/a | `string` | n/a | yes |
| <a name="input_dlq_max_receive_count"></a> [dlq\_max\_receive\_count](#input\_dlq\_max\_receive\_count) | DLQ Max Receive Count | `number` | `3` | no |
| <a name="input_encrypted_queue"></a> [encrypted\_queue](#input\_encrypted\_queue) | Encrypt SQS Queue using KMS | `bool` | `false` | no |
| <a name="input_environment"></a> [environment](#input\_environment) | n/a | `string` | n/a | yes |
| <a name="input_fifo_queue"></a> [fifo\_queue](#input\_fifo\_queue) | FIFO SQS Queue | `bool` | `false` | no |
| <a name="input_infrastructure_support"></a> [infrastructure\_support](#input\_infrastructure\_support) | n/a | `string` | n/a | yes |
| <a name="input_is_production"></a> [is\_production](#input\_is\_production) | n/a | `string` | n/a | yes |
| <a name="input_namespace"></a> [namespace](#input\_namespace) | n/a | `string` | n/a | yes |
| <a name="input_queue_name"></a> [queue\_name](#input\_queue\_name) | SQS Queue Name | `string` | n/a | yes |
| <a name="input_sqs_queue_subscriber_namespaces"></a> [sqs\_queue\_subscriber\_namespaces](#input\_sqs\_queue\_subscriber\_namespaces) | List of namespaces that need to subscribe to the SQS queue, the names provided here must match the namespace tag on the namespace' IRSA service accounts | `list(string)` | n/a | yes |
| <a name="input_sqs_subscriber_roles_regex_filter"></a> [sqs\_subscriber\_roles\_regex\_filter](#input\_sqs\_subscriber\_roles\_regex\_filter) | regex to filter IRSA accounts from all IAM roles in the CP | `string` | `"^cloud-platform-irsa.*"` | no |
| <a name="input_team_name"></a> [team\_name](#input\_team\_name) | n/a | `string` | n/a | yes |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_iam_roles_granted_access"></a> [iam\_roles\_granted\_access](#output\_iam\_roles\_granted\_access) | IRSA Roles Granted Access to SQS |
| <a name="output_irsa_policy_arn"></a> [irsa\_policy\_arn](#output\_irsa\_policy\_arn) | IRSA Policy ARN for SQS Queue |
| <a name="output_sqs_queue_arn"></a> [sqs\_queue\_arn](#output\_sqs\_queue\_arn) | SQS Queue ARN |
<!-- END_TF_DOCS -->