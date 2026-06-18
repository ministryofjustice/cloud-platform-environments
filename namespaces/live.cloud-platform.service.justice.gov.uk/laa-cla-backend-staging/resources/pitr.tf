resource "aws_db_instance", "restored" {

  identifier           = var.db_identifier
  db_subnet_group_name = var.db_subnet_group_name
  
  instance_class = var.instance_class
  engine = var.engine

  restore_to_point_in_time {

    source_db_instance_identifier = var.source_db_instance_identifier, 
    use_latest_restoreable_time = true 

  }

  skip_final_snapshot = true

  tags = {
    name= var.namespace
  }

}