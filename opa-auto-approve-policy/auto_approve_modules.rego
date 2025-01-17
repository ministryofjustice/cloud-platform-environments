package terraform.analysis

import input as tfplan

########################
# Parameters for Policy
########################

resource_addrs := {"module.service_pod.kubernetes_deployment.service_pod", "aws_iam"}

#########
# Policy
#########

default allow := false

default service_pod_ok := false

allow if {
	not touches_iam
	service_pod_ok
}

service_pod_ok if {
	rc := [rc | rc := tfplan.resource_changes[_]]

	service_pods := [p |
		p := rc[_]

		regex.match(`^module\..*\.kubernetes_deployment\.service_pod$`, p.address)
	]

	count(service_pods) > 0

	some r in service_pods

	module_name := concat("", ["module.", r.name, ".kubernetes_deployment.service_pod"])
	is_service_pod_valid[module_name]
}

touches_iam if {
	all_policies := [
	p |
		p := tfplan.resource_changes[_]
		p.type == "aws_iam_policy"
		change := p.change.actions[_]
		change != "no-op"
	]

	count(all_policies) > 0
}

####################
# Terraform Library
####################

# list of all resources of the given type
resources[addr] := all if {
	some addr
	resource_addrs[addr]
	all := [
	name |
		name := tfplan.resource_changes[_]
		name.address == addr
	]
}

is_service_pod_valid[addr] if {
	some addr
	resource_addrs[addr]
	all := resources[addr]

	regex.match(`^module\..*\.kubernetes_deployment\.service_pod$`, addr)

	service_pods := [
	res |
		res := all[_]

		regex.match(`^module\..*\.kubernetes_deployment\.service_pod$`, res.address)
		change := res.change.actions[_]
		change != "no-op"
	]

	# Ensure all service pods match the expected namespace
	actual_ns := [
	res |
		pod_resource := service_pods[_]
		res := pod_resource.change.after.metadata[_].namespace
	]

	is_correct_namespace := [
	n |
		ns := actual_ns[n]
		ns == tfplan.variables.namespace.value
	]

	count(service_pods) > 0
	count(is_correct_namespace) == count(service_pods)
}
