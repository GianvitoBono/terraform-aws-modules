resource "aws_launch_template" "this" {
  name_prefix   = var.app_name
  image_id      = data.aws_ami.selected.id
  instance_type = var.instance_type
  key_name      = var.key_name

  network_interfaces {
    security_groups             = [module.instance_sg.this_security_group_id]
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
      TargetGroupARNs: ${jsonencode([for tg_arn in module.alb.target_group_arns : tg_arn])}
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

  depends_on = [
    module.alb
  ]
}

module "loadbalancer_sg" {
  source  = "terraform-aws-modules/security-group/aws"
  version = "~> 3.0"

  name        = "${var.app_name}-${var.env}-alb-sg"
  description = "Security group for usage with ALB"
  vpc_id      = var.vpc_id

  ingress_cidr_blocks = ["0.0.0.0/0"]
  ingress_rules       = ["http-80-tcp"]
  computed_egress_with_source_security_group_id = [
    {
      rule                     = "http-80-tcp"
      source_security_group_id = module.instance_sg.this_security_group_id
    },
  ]

  number_of_computed_egress_with_source_security_group_id = 1
}

module "instance_sg" {
  source  = "terraform-aws-modules/security-group/aws"
  version = "~> 3.0"

  name        = "${var.app_name}_instances_sg"
  description = "Security group for example usage with EC2 Instances"
  vpc_id      = var.vpc_id

  computed_ingress_with_source_security_group_id = [
    {
      rule                     = "http-80-tcp"
      source_security_group_id = module.loadbalancer_sg.this_security_group_id
    },
  ]

  number_of_computed_ingress_with_source_security_group_id = 1

}

module "alb" {
  source  = "terraform-aws-modules/alb/aws"
  version = "5.10.0"

  name = "${var.app_name}-alb"

  load_balancer_type = "application"

  vpc_id          = var.vpc_id
  security_groups = [module.loadbalancer_sg.this_security_group_id]
  subnets         = var.public_subnets_ids

  http_tcp_listeners = [
    {
      port               = 80
      protocol           = "HTTP"
      target_group_index = 0
    }
  ]

  target_groups = [
    {
      name_prefix          = "h1"
      backend_protocol     = "HTTP"
      backend_port         = 80
      target_type          = "instance"
      deregistration_delay = 10
      health_check = {
        enabled             = true
        interval            = 30
        path                = "/"
        port                = "traffic-port"
        healthy_threshold   = 3
        unhealthy_threshold = 3
        timeout             = 6
        protocol            = "HTTP"
        matcher             = "200-399"
      }
    },
  ]

  tags = {
    "Name" = "${var.app_name}-${var.env}-alb"
    "Env"  = var.env
    "App"  = var.app_name
  }
}