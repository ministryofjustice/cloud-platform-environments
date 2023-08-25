output "alpha_zone_name_servers" {
  value       = try(aws_route53_zone.default[0].name_servers, [])
  description = "Alpha Route53 DNS Zone Name Servers"
}

output "alpha_fqdn" {
  value       = join("", aws_route53_zone.default.*.name)
  description = "Alpha Fully-qualified domain name"
}
