locals {
  tg_arns = [for tg_arn in module.alb.target_group_arns : tg_arn]
}

resource "aws_launch_template" "this" {
  name_prefix   = var.app_name
  image_id      = data.aws_ami.selected.id
  instance_type = var.instance_type
  key_name      = var.key_name

  network_interfaces {
    security_groups             = [aws_security_group.istance_sg.id]
    delete_on_termination       = true
    associate_public_ip_address = true
  }

  user_data = base64encode(var.ec2_user_data)
}

resource "aws_cloudformation_stack" "this" {
  name = "${var.app_name}-stack"

  template_body = <<EOF
Resources:
  ASG:
    Type: AWS::AutoScaling::AutoScalingGroup
    Properties:
      AutoScalingGroupName: "${var.app_name}"
      HealthCheckGracePeriod: ${var.healthcheck_grace_period}
      DesiredCapacity: ${var.asg_desired_capacity}
      MaxSize: ${var.asg_max_size}
      MinSize: ${var.asg_min_size}
      VPCZoneIdentifier: ["${join("\",\"", var.private_subnets_ids)}"]
      TargetGroupARNs: ${jsonencode(local.tg_arns)}
      Tags:
        - Key: "Name"
          PropagateAtLaunch: true
          Value: "${var.app_name}-${var.env}"
        - Key: "Env"
          PropagateAtLaunch: true
          Value: "${var.env}"
        - Key: "App"
          PropagateAtLaunch: true
          Value: "${var.app_name}"
      HealthCheckType: ELB

      MixedInstancesPolicy:
        InstancesDistribution:
          OnDemandBaseCapacity: ${var.asg_ondemand_base_capacity}
          OnDemandPercentageAboveBaseCapacity: ${var.asg_ondemand_percentage}
          SpotAllocationStrategy: ${var.asg_spot_allocation_strategy}
        LaunchTemplate:
          LaunchTemplateSpecification:
            LaunchTemplateName: "${aws_launch_template.this.name}"
            Version: "${aws_launch_template.this.latest_version}"
          Overrides: ${jsonencode([for type in var.instance_type_override : map("InstanceType", type)])}

    UpdatePolicy:
      AutoScalingScheduledAction:
        IgnoreUnmodifiedGroupSizeProperties: true
      AutoScalingRollingUpdate:
        MinSuccessfulInstancesPercent: 50
        PauseTime: PT10M
        SuspendProcesses:
          - HealthCheck
          - ReplaceUnhealthy
          - AZRebalance
          - AlarmNotification
          - ScheduledActions
        WaitOnResourceSignals: true
    DeletionPolicy: Delete
EOF

  depends_on = [module.alb]
}

resource "aws_security_group" "istance_sg" {
  name        = "${var.app_name}_instances_sg"
  description = "Security group for EC2 Instances"
  vpc_id      = var.vpc_id

  ingress {
    description     = "Inbound from ${var.app_name}-lb"
    from_port       = var.asg_target_port
    protocol        = "TCP"
    security_groups = [aws_security_group.loadbalancer_sg.id]
    to_port         = var.asg_target_port
  }
}

resource "aws_security_group" "loadbalancer_sg" {
  name        = "${var.app_name}_loadbalancer_sg"
  description = "Security group for usage with ALB"
  vpc_id      = var.vpc_id

  ingress {
    description = "Inbound from internet"
    cidr_blocks = ["0.0.0.0/0"]
    from_port   = var.lb_port
    protocol    = "TCP"
    to_port     = var.lb_port
  }

  dynamic "ingress" {
    for_each = range(var.lb_enable_http_to_https_redirect ? 1 : 0)

    content {
      cidr_blocks = [ "0.0.0.0/0" ]
      description = "Inbound from internet HTTP"
      from_port = 80
      protocol = "TCP"
      to_port = 80
    }
  }

  egress {
    cidr_blocks = ["0.0.0.0/0"]
    description = "Allow outbound to all"
    from_port   = 0
    to_port     = 0
    protocol    = -1
  }
}

module "alb" {
  source  = "terraform-aws-modules/alb/aws"
  version = "5.10.0"

  name = "${var.app_name}-lb"

  load_balancer_type = var.lb_type

  vpc_id          = var.vpc_id
  security_groups = [aws_security_group.loadbalancer_sg.id]
  subnets         = var.public_subnets_ids

  https_listeners = var.lb_protocol == "HTTPS " ? [
    {
      port               = var.lb_port
      protocol           = var.lb_protocol
      certificate_arn    = var.lb_certificate_arn
      target_group_index = 0
    }
  ] : []

  http_tcp_listeners = var.lb_enable_http_to_https_redirect && var.lb_protocol == "HTTPS" ? [
    {
      port        = 80
      protocol    = "HTTP"
      action_type = "redirect"
      redirect = {
        port        = var.lb_port
        protocol    = "HTTPS"
        status_code = "HTTP_301"
      }
    }
  ] : [
    {
      port               = var.lb_port
      protocol           = var.lb_protocol
      target_group_index = 0
    }
  ]

  target_groups = [
    {
      name_prefix          = "h1"
      backend_protocol     = var.asg_target_protocol
      backend_port         = var.asg_target_port
      target_type          = "instance"
      deregistration_delay = 10
      health_check = {
        enabled             = var.lb_heathcheck_enabled
        interval            = var.lb_heathcheck_interval
        path                = var.lb_heathcheck_path
        port                = "traffic-port"
        healthy_threshold   = var.lb_heathcheck_healthy_threshold
        unhealthy_threshold = var.lb_heathcheck_unhealthy_threshold
        timeout             = 6
        protocol            = var.asg_target_protocol
        matcher             = var.lb_heathcheck_matcher
      }
    },
  ]

  tags = {
    "Name" = "${var.app_name}-${var.env}-alb"
    "Env"  = var.env
    "App"  = var.app_name
  }
}