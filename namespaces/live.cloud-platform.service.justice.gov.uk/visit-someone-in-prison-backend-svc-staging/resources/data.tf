# use dev topic arn as there is no staging for domain events
data "aws_ssm_parameter" "hmpps-domain-events-topic-arn" {
  name = "/hmpps-domain-events-dev/topic-arn"
}