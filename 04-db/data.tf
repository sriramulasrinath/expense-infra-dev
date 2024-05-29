data "aws_ssm_parameter" "db_sg_id" {
    name = "/${var.project_name}/Dev/db_sg_id"
}
data "aws_ssm_parameter" "database_subnet_group_name" {
  name = "/${var.project_name}/Dev/database_subnet_group_name"
}