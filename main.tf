provider "aws" {
  region = "eu-central-1"
}

resource "random_string" "rds_pass" {
  length           = 12
  special          = true
  override_special = "!@#$"
}

resource "aws_ssm_parameter" "rds_pass" {
  name        = "/prod/mysql"
  description = "Master Pass for RDS MySQl"
  type        = "SecureString"
  value       = random_string.rds_pass.result
}


data "aws_ssm_parameter" "my_rds_pass" {
  name = "/prod/mysql"

  depends_on = [aws_ssm_parameter.rds_pass]
}
output "rds_pass" {
  value     = data.aws_ssm_parameter.my_rds_pass.value
  sensitive = true
}

resource "aws_db_instance" "default" {
  allocated_storage    = 10
  db_name              = "mydb"
  engine               = "mysql"
  engine_version       = "5.7"
  instance_class       = "db.t3.micro"
  username             = "admin"
  password             = data.aws_ssm_parameter.my_rds_pass.value
  parameter_group_name = "default.mysql5.7"
  skip_final_snapshot  = true
  apply_immediately    = true
  identifier           = "myrds"
}
