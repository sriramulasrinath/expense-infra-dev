variable "project_name" {
    default = "expense"
}
variable "environment" {
    default = "dev"
}
variable "common_tags" {
  default = {
    Project = "expense"
    environment = "dev"
    Terraform = "true"
    component = "backend"
  }
}
variable "zone_name" {
  default = "srinath.online"
}