 # convert StringList to list and get first element
locals {
  private_subnet_id = element(split(",", data.aws_ssm_parameter.private_subnet_ids.value), 0)
}