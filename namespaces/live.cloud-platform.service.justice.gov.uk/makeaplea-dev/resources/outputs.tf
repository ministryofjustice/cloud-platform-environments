output "irsa_policy_arn" {
  value = module.makeaplea_queue.irsa_policy_arn
}

output "sqs_id_arn" {
  value = module.makeaplea_queue.assume_role_policy.arn
}
