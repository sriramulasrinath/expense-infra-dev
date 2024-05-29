variable "project_name" {
    default = "expense"
}
variable "environment" {
    default = "Dev"
}
variable "common_tags" {
  default = {
    Project = "expense"
    Environment = "dev"
    Terraform = "true"
  }
}