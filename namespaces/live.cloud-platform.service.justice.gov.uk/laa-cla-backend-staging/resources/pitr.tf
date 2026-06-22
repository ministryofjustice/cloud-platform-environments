resource "aws_db_instance" "restored" {
  identifier             = var.db_identifier
  instance_class         = var.db_instance_class
  engine_version         = var.db_engine_version

  db_subnet_group_name   = var.db_subnet_group_name
  vpc_security_group_ids = var.vpc_security_group_ids

  restore_to_point_in_time {
    source_db_instance_identifier = module.cla_backend_rds_postgres_14.db_identifier
    use_latest_restorable_time    = true
  }

  skip_final_snapshot = true

  tags = {
    Name = var.namespace
  }
}