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
	every irsa in all_irsa {
		every action in irsa.change.actions {
			action == "no-op"
		}
	}

	all_irsa_accounts := [
	name |
		irsa := all_irsa[_]
		name := irsa.change.after.metadata[_].name
	]

	all_irsa_ns := [
	ns |
		irsa := all_irsa[_]
		ns := irsa.change.after.metadata[_].namespace
	]

	service_pods_service_accounts := [
	res |
		res := service_pod.change.after.spec[_].template[_].spec[_].service_account_name
	]
	count(service_pods_service_accounts) > 0

	every sa in service_pods_service_accounts {
		sa in all_irsa_accounts
	}

	every ns in actual_ns {
		ns in all_irsa_ns
	}

	touches_others := [
	c |
		c := tfplan.resource_changes[_]
		not regex.match(`^module\..*\.kubernetes_deployment\.service_pod$`, c.address)
		not regex.match(`^module\..*\.random_id\.name$`, c.address)
		change := c.change.actions[_]
		change != "no-op"
	]

	count(touches_others) == 0
}
