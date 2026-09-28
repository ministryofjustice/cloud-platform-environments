# ------------------------------------------------------------
# Security group for the Route 53 outbound resolver
# ------------------------------------------------------------

resource "aws_security_group" "lecn_dns_resolver" {
  name        = "srrc-lecn-dns-resolver"
  description = "Security group for DNS forwarding to LECN"
  vpc_id      = data.aws_vpc.this.id

  tags = {
    business-unit          = var.business_unit
    application            = var.application
    is-production          = var.is_production
    team_name              = var.team_name
    namespace              = var.namespace
    environment-name       = var.environment
    infrastructure-support = var.infrastructure_support
  }
}


# ------------------------------------------------------------
# Allow DNS requests into the resolver from our VPC
# ------------------------------------------------------------

resource "aws_security_group_rule" "lecn_dns_resolver_ingress_tcp" {
  type              = "ingress"
  security_group_id = aws_security_group.lecn_dns_resolver.id

  protocol  = "tcp"
  from_port = 53
  to_port   = 53

  cidr_blocks = [
    data.aws_vpc.this.cidr_block
  ]
}

resource "aws_security_group_rule" "lecn_dns_resolver_ingress_udp" {
  type              = "ingress"
  security_group_id = aws_security_group.lecn_dns_resolver.id

  protocol  = "udp"
  from_port = 53
  to_port   = 53

  cidr_blocks = [
    data.aws_vpc.this.cidr_block
  ]
}


# ------------------------------------------------------------
# Allow resolver to send DNS requests to LECN DNS servers
# ------------------------------------------------------------

resource "aws_security_group_rule" "lecn_dns_resolver_egress_tcp" {
  type              = "egress"
  security_group_id = aws_security_group.lecn_dns_resolver.id

  protocol  = "tcp"
  from_port = 53
  to_port   = 53

  cidr_blocks = [
    "51.231.189.93/32",
    "51.231.189.125/32"
  ]
}

resource "aws_security_group_rule" "lecn_dns_resolver_egress_udp" {
  type              = "egress"
  security_group_id = aws_security_group.lecn_dns_resolver.id

  protocol  = "udp"
  from_port = 53
  to_port   = 53

  cidr_blocks = [
    "51.231.189.93/32",
    "51.231.189.125/32"
  ]
}


# ------------------------------------------------------------
# Route 53 outbound resolver endpoint
# ------------------------------------------------------------

resource "aws_route53_resolver_endpoint" "lecn" {
  name      = "srrc-lecn-outbound"
  direction = "OUTBOUND"

  security_group_ids = [
    aws_security_group.lecn_dns_resolver.id
  ]

  dynamic "ip_address" {
    for_each = data.aws_subnet.this

    content {
      subnet_id = ip_address.value.id
    }
  }

  tags = {
    business-unit          = var.business_unit
    application            = var.application
    is-production          = var.is_production
    team_name              = var.team_name
    namespace              = var.namespace
    environment-name       = var.environment
    infrastructure-support = var.infrastructure_support
  }
}


# ------------------------------------------------------------
# Forward BSG preprod DNS queries to LECN
# ------------------------------------------------------------

resource "aws_route53_resolver_rule" "bsg_preprod" {
  name        = "srrc-bsg-preprod"
  domain_name = "prp1bsg.govserve.homeoffice.gov.uk"
  rule_type   = "FORWARD"

  resolver_endpoint_id = aws_route53_resolver_endpoint.lecn.id

  target_ip {
    ip   = "51.231.189.93"
    port = 53
  }

  target_ip {
    ip   = "51.231.189.125"
    port = 53
  }
}


# ------------------------------------------------------------
# Apply the forwarding rule to the VPC
# ------------------------------------------------------------

resource "aws_route53_resolver_rule_association" "bsg_preprod" {
  name = "srrc-bsg-preprod"

  resolver_rule_id = aws_route53_resolver_rule.bsg_preprod.id
  vpc_id           = data.aws_vpc.this.id
}