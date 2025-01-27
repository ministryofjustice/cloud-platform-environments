package terraform.analysis

import input as tfplan

default allow := false

default service_pod_ok := false

allow if {
	not touches_iam
	service_pod_ok
}

touches_iam if {
	all_iam := [
	p |
		p := tfplan.resource_changes[_]
		p.type in {"aws_iam_policy", "aws_iam_role_policy_attachment"}
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
