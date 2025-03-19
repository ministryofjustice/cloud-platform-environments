package terraform.analysis

import input as tfplan

default allow := false

default service_pod_ok := false

default touches_iam := true

allow if {
	service_pod_ok
}

service_pod_ok if {
	service_pods := [
	res |
		res := tfplan.resource_changes[_]
		regex.match(`^module\..*\.kubernetes_deployment\.service_pod$`, res.address)
		res.change.actions[_] != "no-op"
	]

	every sp in service_pods {
		is_service_pod_valid(sp)
	}
}
