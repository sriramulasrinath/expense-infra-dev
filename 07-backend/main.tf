module "backend" {
  source  = "terraform-aws-modules/ec2-instance/aws"

  name = "${var.project_name}-${var.environment}-${var.common_tags.component}"

  instance_type          = "t2.micro"
  vpc_security_group_ids = [data.aws_ssm_parameter.backend_sg_id.value]
    # convert StringList to list and get first element
  subnet_id              = local.private_subnet_id
  ami                    = data.aws_ami.ami_info.id

  tags = merge(
    var.common_tags,
    {
        name = "${var.project_name}-${var.environment}-${var.common_tags.component}"
    }
  )
}
##############################################
      #### NULL RESOURCE ####
#############################################
resource "null_resource" "backend" {
 
  triggers = {
    instance_id = module.backend.id  # this will be triggered everytime instance is created
  }
  connection {
    type     = "ssh"
    user     = "ec2-user"
    password = "DevOps321"
    host     = module.backend.private_ip
    }

    provisioner "file" {
    source      = "${var.common_tags.component}.sh"
    destination = "/tmp/${var.common_tags.component}.sh"
    }
    provisioner "remote-exec" {
      inline = [ 
        "chmod +x /tmp/${var.common_tags.component}.sh",
         "sudo sh /tmp/${var.common_tags.component}.sh ${var.common_tags.component} ${var.environment}"
       ]
    }
}
##############################################
      #### STOPPING AMI ####
#############################################
resource "aws_ec2_instance_state" "backend" {
  instance_id = module.backend.id
  state       = "stopped"

  depends_on = [ null_resource.backend ]
} 
##############################################
      #### TO TAKE AMI ####
#############################################
resource "aws_ami_from_instance" "backend" {
  name               = "${var.project_name}-${var.environment}-${var.common_tags.component}"
  source_instance_id = module.backend.id

  depends_on = [ aws_ec2_instance_state.backend ]
}
############################################################
      #### TERMINATE INSTANCE USING AWS CLI-LOCAL_EXEC ####
############################################################
  resource "null_resource" "backend_delete" {
    triggers = {
      instance_id = module.backend.id # this will be triggered everytime instance is created
    }
    provisioner "local-exec" {
        command = "aws ec2 terminate-instances --instance-ids ${module.backend.id}"
    } 

    depends_on = [ aws_ami_from_instance.backend ]
}
##############################################
      #### CREATING A TARGET GROUP ####
#############################################
resource "aws_lb_target_group" "backend" {
  name     = "${var.project_name}-${var.environment}-${var.common_tags.component}"
  port     = 8080
  protocol = "HTTP"
  vpc_id   = data.aws_ssm_parameter.vpc_id.value

  health_check {
    path                = "/health"
    port                = 8080
    protocol            = "HTTP"
    healthy_threshold   = 2
    unhealthy_threshold = 2
    matcher             = "200"
  }
}
##############################################
      #### CREATING A LAUNCH TEMPLATE ####
#############################################

resource "aws_launch_template" "backend" {
  name = "${var.project_name}-${var.environment}-${var.common_tags.component}"
  image_id = aws_ami_from_instance.backend.id
  instance_initiated_shutdown_behavior = "terminate"
  update_default_version = true # sets the latest version to default        

  instance_type = "t2.micro"

  vpc_security_group_ids = [data.aws_ssm_parameter.backend_sg_id.value]

  tag_specifications {
    resource_type = "instance"

    tags = merge(
      var.common_tags,
      {
        Name = "${var.project_name}-${var.environment}-${var.common_tags.component}"
      }
    )
  }
}
##############################################
      #### CREATING AUTOSCALING GROUP ####
#############################################
resource "aws_autoscaling_group" "backend" {
  name                      = "${var.project_name}-${var.environment}-${var.common_tags.component}"
  max_size                  = 2
  min_size                  = 1
  health_check_grace_period = 60
  health_check_type         = "ELB"
  desired_capacity          = 1
  target_group_arns = [aws_lb_target_group.backend.arn]
  launch_template {
    id      = aws_launch_template.backend.id
    version = "$Latest"
  }

  vpc_zone_identifier       = split(",", data.aws_ssm_parameter.private_subnet_ids.value)

  instance_refresh {
    strategy = "Rolling"
    preferences {
      min_healthy_percentage = 50
    }
    triggers = ["launch_template"]
  }

  tag {
    key                 = "Name"
    value               = "${var.project_name}-${var.environment}-${var.common_tags.component}"
    propagate_at_launch = true
  }

  timeouts {
    delete = "15m"
  }

  tag {
    key                 = "Project"
    value               = "${var.project_name}"
    propagate_at_launch = false
  }
}
##############################################
      #### AUTO SCALLING POLICY  ####
#############################################
 resource "aws_autoscaling_policy" "backend" {
  name                   =  "${var.project_name}-${var.environment}-${var.common_tags.component}"
  policy_type            = "TargetTrackingScaling"
  autoscaling_group_name = aws_autoscaling_group.backend.name

   target_tracking_configuration {
    predefined_metric_specification {
      predefined_metric_type = "ASGAverageCPUUtilization"
    }

    target_value = 7.0
  }
}
##############################################
      #### aws_lb_listener_rule  ####
#############################################
resource "aws_lb_listener_rule" "backend" {
  listener_arn = data.aws_ssm_parameter.app_alb_listener_arn.value
  priority     = 100 # less number will be first validated

  action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.backend.arn
  }

  condition {
    host_header {
      values = ["backend.app-${var.environment}.${var.zone_name}"]
    }
  }
}