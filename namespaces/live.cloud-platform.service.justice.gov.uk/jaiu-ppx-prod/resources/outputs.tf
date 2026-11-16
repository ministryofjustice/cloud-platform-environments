output "ppx_document_bucket_name" {
  description = "Private versioned document bucket; delete-deny policy is owned by this namespace"
  value       = module.documents_bucket.bucket_name
}

output "ppx_legacy_export_bucket_name" {
  description = "Private legacy-export bucket; no production workload role is granted access"
  value       = module.legacy_exports_bucket.bucket_name
}

output "ppx_database_host" {
  description = "Private PostgreSQL hostname"
  value       = module.rds.rds_instance_address
}

output "ppx_database_name" {
  description = "Application database name"
  value       = module.rds.database_name
}
