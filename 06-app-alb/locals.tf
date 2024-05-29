 # convert StringList to list and get first element
locals {
  public_subnet_id = split(",", data.aws_ssm_parameter.private_subnet_ids.value)
}