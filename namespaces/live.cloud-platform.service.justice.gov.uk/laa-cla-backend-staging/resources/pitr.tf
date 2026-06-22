resource "aws_db_instance" "restored" {
  identifier     = var.db_identifier
  instance_class = var.db_instance_class
  engine_version = var.db_engine_version

  restore_to_point_in_time {
    source_db_instance_identifier = [data.aws_db_instance.existing.db_instance_identifier]
    use_latest_restorable_time    = true
  }

  skip_final_snapshot = true

  tags = {
    Name = var.namespace
  }
}