package terraform.analysis

import input as tfplan

########################
# Parameters for Policy
########################

# Consider exactly these resource types in calculations
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
	is_service_pod_valid["module.service_pod.kubernetes_deployment.service_pod"]
}

touches_iam if {
	all_policies := [p |
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

# list of all resources of a given type
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

	regex.match(`.*\.service_pod$`, addr)

	service_pods := [
	res |
		res := all[_]
		res.address == "module.service_pod.kubernetes_deployment.service_pod"
		change := res.change.actions[_]
		change != "no-op"
	]

	# Ensure all service pods match the expected namespace
	actual_ns := [res |
		pod_resource := service_pods[_]
		res := pod_resource.change.after.metadata[_].namespace
	]

	is_correct_namespace := [n |
		ns := actual_ns[n]
		ns == "tim-development"
	]
	count(is_correct_namespace) == count(service_pods)
}
