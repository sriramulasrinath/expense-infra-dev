  resource "aws_key_pair" "vpn" {
    key_name   = "openvpn"
    # public_key = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIMJl3b80vJaW3FdN2v87ag3U63EfTdSAWdH+W+wBGiva"
    public_key = file("~/.ssh/openvpn.pub")
    }


module "vpn" {
  source  = "terraform-aws-modules/ec2-instance/aws"
  name = "${var.project_name}-${var.environment}-vpn"
  key_name = aws_key_pair.vpn.key_name

  instance_type          = "t3.micro"
  vpc_security_group_ids = [data.aws_ssm_parameter.vpn_sg_id.value]
    # convert StringList to list and get first element
  subnet_id              = local.public_subnet_id
  ami                    = data.aws_ami.ami_info.id

  tags = merge(
    var.common_tags,
    {
        name = "${var.project_name}-${var.environment}-vpn"
    }
  )
}