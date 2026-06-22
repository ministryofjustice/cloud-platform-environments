resource "aws_db_instance" "restored" {
  identifier             = var.db_identifier
  instance_class         = var.db_instance_class
  engine_version         = var.db_engine_version


  restore_to_point_in_time {
    source_db_instance_identifier = module.cla_backend_rds_postgres_14.db_instance_identifier
    use_latest_restorable_time    = true
  }

  skip_final_snapshot = true

  tags = {
    Name = var.namespace
  }
}