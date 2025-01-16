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

default score := 100


score := 0 if {
    res := is_namespace_valid[addr]
    print(addr)
    print(res)
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
    all := [
        name |
        name := tfplan.resource_changes[_]
        name.address == addr
    ]
}



is_namespace_valid[addr] if {
    some addr
    resource_addrs[addr]
    all := resources[addr]
    print(addr)

    # Filter the service pod resources
    service_pods := [res | res := all[_]; res.address == "module.service_pod.kubernetes_deployment.service_pod"]

    # Ensure all service pods match the expected namespace
    
    actual_ns := [ res | 
        pod_resource := service_pods[_]
        res := pod_resource.change.after.metadata[_].namespace
        
    
    ]
    print(actual_ns)
    
    # result if { every ns in actual_ns { ns == "asdf" } }
    is_correct_namespace := [n | ns := actual_ns[n]
    ns == "tim-development"
    ]
    print(is_correct_namespace)
    count(is_correct_namespace) == count(service_pods)
}