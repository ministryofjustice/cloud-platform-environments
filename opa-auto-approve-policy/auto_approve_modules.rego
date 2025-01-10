package terraform.analysis

import input as tfplan

########################
# Parameters for Policy
########################

# acceptable score for automated authorization
blast_radius := 30

# Consider exactly these resource types in calculations
resource_addrs := {"module.service_pod.kubernetes_deployment.service_pod", "aws_iam"}

#########
# Policy
#########

# Authorization holds if score for the plan is acceptable and no changes are made to IAM
default authz := false

authz if {
	score < blast_radius
	not touches_iam
}

# Compute the score for a Terraform plan as the weighted sum of deletions, creations, modifications
# score := s if {
# 	all := [x |
# 		some resource_addr in
#         x := 100

#         x := 0 if {
#             is_array_namespaces_valid[resource_addr] == true    
#         } 

# 	]
# 	s := sum(all)
# }
default score := 100
score := 0   if { 
    is_namepsace_valid[resource_addr] == true 
    }


# Whether there is any change to IAM
touches_iam if {
	all := resources.aws_iam
	count(all) > 0
}

####################
# Terraform Library
####################

# list of all resources of a given type
resources[addr] := all if {
	some addr
	resource_addrs[addr]
	all := [name |
		name := tfplan.resource_changes[_]
		name.address == addr
	]
}

is_namepsace_valid[addr] := is_array_namespaces_valid if {
	some addr
	resource_addrs[addr]
	all := resources[addr]

# We need to check the service pod
	# service_pods := [res | res := all[_]; res.address == "module.service_pod.kubernetes_deployment.service_pod"
    # res := "tim-development"]
    service_pods := ["tim-development"]

# We need to check if the service pod is in the same namespace 

        # every r in service_pods
        # r.change.after.metadata.namespace == tfplan.variables.namespace.value
        # r == "tim-development"
        is_array_namespaces_valid := true

    
}