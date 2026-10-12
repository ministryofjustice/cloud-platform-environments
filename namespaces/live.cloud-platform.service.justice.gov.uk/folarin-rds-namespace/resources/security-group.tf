# Commented out rather than deleted, so it can be reused if this namespace needs to
# be reachable from a Container Platform cluster again. To bring it back, uncomment
# the block, confirm the node CIDR still matches the cluster, and reattach the
# security group to the RDS module with vpc_security_group_ids.

# data "aws_vpc" "selected" {
#   filter {
#     name   = "tag:Name"
#     values = [var.vpc_name == "live" ? "live-1" : var.vpc_name]
#   }
# }

# resource "aws_security_group" "rds" {
#   name        = "${var.namespace}-rds-sg"
#   description = "Allow Container Platform (CP3) access to the test app demo database"
#   vpc_id      = data.aws_vpc.selected.id
#
#   lifecycle {
#     create_before_destroy = true
#   }
# }

# Node CIDR, not the pod CIDR: the VPC CNI SNATs pod traffic to the node primary ENI
# for destinations outside the cluster VPC.
# resource "aws_security_group_rule" "rds_inbound_cp3_octo_nonlive" {
#   type              = "ingress"
#   description       = "container-platform-octo-nonlive nodes"
#   from_port         = 5432
#   to_port           = 5432
#   protocol          = "tcp"
#   security_group_id = aws_security_group.rds.id
#   cidr_blocks       = ["10.195.48.0/20"]
# }
