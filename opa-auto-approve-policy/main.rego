package terraform.analysis

import input as tfplan

default allow := false

default service_pod_ok := false
default ecr_create_ok := false

allow if {
	# modify to ignore ecr IAM changes
	not touches_iam
	# split this since users won't use both at the same time.
	service_pod_ok
	ecr_create_ok
}

touches_iam if {
	all_iam := [
	p |
		p := tfplan.resource_changes[_]
		p.type in {"aws_iam_policy", "aws_iam_role_policy_attachment"}
		# Ignore IAM resources in the ecr module
		not regex.match(`module\.ecr`, p.module_address)
		change := p.change.actions[_]
		change != "no-op"
	]

	count(all_iam) > 0
}

service_pod_ok if {
	service_pods := [
	res |
		res := tfplan.resource_changes[_]
		regex.match(`^module\..*\.kubernetes_deployment\.service_pod$`, res.address)
		res.change.actions[_] != "no-op"
	]

	count(service_pods) > 0
	every sp in service_pods {
		is_service_pod_valid(sp)
	}
}

ecr_create_ok if {
	ecrs := [
	res |
		res := tfplan.resource_changes[_]
		regex.match(`module\.ecr`, res.module_address)
		regex.match(`aws_ecr_repository`, res.type)
		res.change.actions[_] == "create"
	]

	print("ECR:", ecrs)

	count(ecrs) > 0
	every ecr in ecrs {
		is_ecr_create_valid(ecr)
	}
}
