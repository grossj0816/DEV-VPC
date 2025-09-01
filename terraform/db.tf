resource "aws_db_instance" "rds_dev_instance" {
  allocated_storage      = 20
  db_name                = "rds_dev_instance"
  engine                 = "mysql"
  engine_version         = "8.4.6"
  instance_class         = "db.t3.micro"
  username               = var.username
  password               = var.password
  skip_final_snapshot    = true
  db_subnet_group_name   = aws_db_subnet_group.test_db_subnet_group.id
  vpc_security_group_ids = [aws_security_group.db_sg.id]
  publicly_accessible    = false
  apply_immediately      = true
}