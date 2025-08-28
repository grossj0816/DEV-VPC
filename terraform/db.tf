resource "aws_db_instance" "test_db_01" {
  allocated_storage      = 20
  db_name                = ""
  engine                 = ""
  engine_version         = ""
  instance_class         = ""
  username               = ""
  password               = ""
  skip_final_snapshot    = true
  db_subnet_group_name   = ""
  vpc_security_group_ids = []
  publicly_accessible    = false
  apply_immediately      = true
}