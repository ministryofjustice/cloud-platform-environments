output "alpha_zone_name_servers" {
  value       = try(aws_route53_zone.data_platform_apps_alpha_route53_zone.name_servers, [])
  description = "Alpha Route53 DNS Zone Name Servers"
}
