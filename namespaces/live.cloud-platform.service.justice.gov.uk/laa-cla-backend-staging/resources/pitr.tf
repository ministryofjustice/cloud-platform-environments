resource "aws_db_instance", "restored" {

  identifier           = var.db_identifier
  db_subnet_group_name = var.db_subnet_group_name
  instance_class = var.instance_class
  engine = var.engine


  identifier ="cla_backend_rds_postgres_14_pitr", 
  instance_class = "db.t4g.small", 
  engine="postgres"


  db_subnet_group_name = ""
  vpc_secruity_group_ids =[]

  restore_to_point_in_time {

    source_db_instance_identifier = "", 
    use_latest_restoreable_time = true 

  }

  skip_final_snapshot = true

  tags = {
    name= var.namespace
  }

}