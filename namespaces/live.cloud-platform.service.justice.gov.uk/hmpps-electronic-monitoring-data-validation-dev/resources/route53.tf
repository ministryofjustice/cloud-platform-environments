resource "aws_route53_zone" "data_validation_route53_zone" {
  name = var.domain

  tags = {
    team_name              = var.team_name
    business-unit          = var.business_unit
    application            = var.application
    is-production          = var.is_production
    environment-name       = var.environment
    owner                  = var.github_owner
    infrastructure-support = var.infrastructure_support
    namespace              = var.namespace
  }
}

resource "aws_security_group" "aws_dns_resolver" {
  name        = "dns-resolver"
  description = "Security Group for DNS resolver request"
  vpc_id      = data.aws_vpc.this.id

  tags = local.tags
}

resource "aws_security_group_rule" "ingress_dns_endpoint_traffic" {
  for_each          = local.dns_endpoint_rules
  description       = format("VPC to DNS Endpoint traffic for %s %d", each.value.protocol, each.value.from_port)
  from_port         = each.value.from_port
  protocol          = each.value.protocol
  security_group_id = aws_security_group.aws_dns_resolver.id
  to_port           = each.value.to_port
  type              = "ingress"
  cidr_blocks       = [data.aws_vpc.this.cidr_block]
}

resource "aws_security_group_rule" "egress_dns_endpoint_traffic" {
  for_each          = local.dns_endpoint_rules
  description       = format("DNS Endpoint to Domain Controller traffic for %s %d", each.value.protocol, each.value.from_port)
  from_port         = each.value.from_port
  protocol          = each.value.protocol
  security_group_id = aws_security_group.aws_dns_resolver.id
  to_port           = each.value.to_port
  type              = "egress"
  cidr_blocks       = [for subnet_key in local.subnets : "${jsondecode(data.aws_secretsmanager_secret_version.dns_resolver_ip.secret_string)[subnet_key]}"]
}

resource "aws_route53_resolver_endpoint" "outbound_api" {
  name      = "outbound-resolve-mod-plat"
  direction = "OUTBOUND"

  security_group_ids = [aws_security_group.aws_dns_resolver.id]

  dynamic "ip_address" {
    for_each = data.aws_subnet.this
    content {
      subnet_id = ip_address.value.id
    }
  }

  tags = local.tags
}

resource "aws_route53_resolver_rule" "em_api_gateway" {
  name                 = "em-api-gateway"
  domain_name          = jsondecode(data.aws_secretsmanager_secret_version.dns_resolver_domain.secret_string)["name"]
  rule_type            = "FORWARD"
  resolver_endpoint_id = aws_route53_resolver_endpoint.outbound_api.id

  dynamic "target_ip" {
    for_each = toset(local.ips)
    
    content {
      ip   = jsondecode(data.aws_secretsmanager_secret_version.dns_resolver_ip.secret_string)[target_ip.value]
      port = 53
    }
  }
}

resource "aws_route53_resolver_rule_association" "forward_to_vpc" {
  name             = "em-core-vpc-private-api-domain"
  resolver_rule_id = aws_route53_resolver_rule.em_api_gateway.id
  vpc_id           = data.aws_vpc.this.id
}
