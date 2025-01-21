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

# get separated by opa fmt
touches_iam if {
	all_policies_attachments := [
	pa |
		pa := tfplan.resource_changes[_]
		pa.type == "aws_iam_role_policy_attachment"
		change := pa.change.actions[_]
		change != "no-op"
	]
	count(all_policies_attachments) > 0
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

	# Get all irsa accounts
	irsa_accounts := [
	name |
		res := tfplan.resource_changes[_]
		regex.match(`^module\..*\.kubernetes_service_account\.generated_sa$`, res.address)
		change := res.change.actions[_]
		change = "no-op"
		name := res.change.after.metadata[_].name
	]
	print(irsa_accounts)

	# Get IRSA role in all service pods
	service_pods_service_accounts := [
	res |
		pod_sa := service_pods[_]
		res := pod_sa.change.after.spec[_].template[_].spec[_].service_account_name
	]
	print(service_pods_service_accounts)

	# Ensure all service pod assigned roles are from the same namespace IRSA
	count(service_pods_service_accounts) > 0
	every service_pods_service_account in service_pods_service_accounts {
		service_pods_service_account in irsa_accounts
	}
}
