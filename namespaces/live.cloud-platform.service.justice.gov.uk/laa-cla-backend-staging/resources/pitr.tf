resource "aws_db_instance" "pitr_restore" {
  identifier = "cla_backend_staging-pitr"

  restore_to_point_in_time {
    source_db_instance_identifier = var.namespace # databse it's coming from cla backend database
    restore_time                 = "2026-06-17T13:47:10+00:00"
  }

  publicly_accessible = false

  tags = {
    Name        = var.namespace
    Environment = var.environment-name
  }
}

output "db_instance_identifier" {
  description = "RDS instance identifier"
  value       = aws_db_instance.pitr_restore.id
}

output "db_instance_arn" {
  description = "RDS instance ARN"
  value       = aws_db_instance.pitr_restore.arn
}

output "db_endpoint" {
  description = "Database endpoint"
  value       = aws_db_instance.pitr_restore.endpoint
}

output "db_address" {
  description = "Database hostname"
  value       = aws_db_instance.pitr_restore.address
}

output "db_port" {
  description = "Database port"
  value       = aws_db_instance.pitr_restore.port
}

output "db_name" {
  description = "Database name"
  value       = aws_db_instance.pitr_restore.db_name
}