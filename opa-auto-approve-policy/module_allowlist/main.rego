package terraform.analysis

import input as tfplan

default allow := false

allow if {
	ecr_exists
}

allow if {
	service_pod_exists
}

ecr_exists if {
	ecrs := [
	res |
		res := tfplan.resource_changes[_]
		regex.match(`module\.ecr`, res.module_address)
		regex.match(`aws_ecr_repository`, res.type)
	]
	count(ecrs) > 0
}

service_pod_exists if {
	service_pods := [
	res |
		res := tfplan.resource_changes[_]
		regex.match(`^module\..*\.kubernetes_deployment\.service_pod$`, res.address)
	]
	count(service_pods) > 0
}
