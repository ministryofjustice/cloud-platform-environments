package terraform.analysis

import input as tfplan

is_service_pod_valid(service_pod) if {
	actual_ns := [
	ns |
		ns := service_pod.change.after.metadata[_].namespace
	]

	is_correct_namespace := tfplan.variables.namespace.value
	every ns in actual_ns {
		ns == is_correct_namespace
	}

	all_irsa := [
	res |
		res := tfplan.resource_changes[_]
		regex.match(`^module\..*\.kubernetes_service_account\.generated_sa$`, res.address)
	]

	all_irsa_account_names := [
	name |
		irsa := all_irsa[_]
		name := irsa.change.after.metadata[_].name
	]

	service_pods_sa := [
	res |
		res := service_pod.change.after.spec[_].template[_].spec[_].service_account_name
	]
	count(service_pods_sa) > 0

	every sa in service_pods_sa {
		sa in all_irsa_account_names
	}

	touches_other_resources := [
	c |
		c := tfplan.resource_changes[_]
		not regex.match(`^module\..*\.kubernetes_deployment\.service_pod$`, c.address)
		not regex.match(`^module\..*\.random_id\.name$`, c.address)
		change := c.change.actions[_]
		change != "no-op"
	]

	count(touches_other_resources) == 0
}
