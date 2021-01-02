# General

variable "app_name" {
  type        = string
  description = "Application name and tag, this will be used to name resources"
  default = "sample-app"
}

variable "aws_region" {
  type        = string
  description = "AWS Region where all the resources will be created"
  default = "us-east-1"
}

variable "env" {
  type        = string
  description = "Enviroment name (prod, dev, stage, etc..), used for tagging and naming resources"
  default     = "test"
}

# Networking

variable "private_subnets_ids" {
  type        = list(string)
  description = "List of private subnets ids where the application shoud run"
  default = []
}

variable "public_subnets_ids" {
  type        = list(string)
  description = "List of public subnets ids where the load balancer shoud run"
  default = []
}

variable "vpc_id" {
  type        = string
  description = "VPC id where the resources will be deployed"
  default = ""
}

# Lauch template

variable "ami_name_prefix" {
  type        = string
  description = "This will be used as a filter to choose the AMI for the lauch template"
  default = "sample-app"
}

variable "key_name" {
  type        = string
  description = "Key name used for the EC2 istances"
  default = ""
}

variable "ec2_user_data" {
  type        = string
  description = "EC2 user data to add to the lauch group, default = empty"
  default     = ""
}

variable "instance_type" {
  type        = string
  description = "Default EC2 instance type to be used in the launch_configuration"
  default     = "t2.micro"
}

# Auto-scaling Group

variable "asg_max_size" {
  type        = number
  description = "Maximum number of EC2 istance running in the ASG (default 2)"
  default     = 2
}

variable "asg_min_size" {
  type        = number
  description = "Minimum number of EC2 istance running in the ASG (default 2)"
  default     = 1
}

variable "healthcheck_grace_period" {
  type        = number
  description = "Heat check grace period for the ASG, default 300"
  default     = 300
}

variable "asg_desired_capacity" {
  type        = number
  description = "Desired capacity for the ASG. default = 1"
  default     = 1
}

variable "instance_type_override" {
  type        = list(string)
  description = "List of EC2 instance types to overwrite on launch_configuration"
  default     = []
}

variable "asg_ondemand_percentage" {
  type        = number
  description = "Percentage of the on-demand capacity for the ASG, default = 20, so 20% on-demand 80% spot"
  default     = 20
}

variable "asg_ondemand_base_capacity" {
  type        = number
  description = "Number of base on-demand EC2, default = 1"
  default     = 1
}

variable "asg_spot_allocation_strategy" {
  type        = string
  description = "ASG spot allocation strategy, this can be lowest-price or capacity-optimized, default = capacity-optimized"
  default     = "capacity-optimized"
}

# Load Balancer vars

variable "lb_port" {
  type        = number
  description = "Exposed load balancer port"
  default     = "80"
}

variable "lb_protocol" {
  type        = string
  description = "Protocol for the load balancer"
  default     = "HTTP"
}

variable "asg_target_port" {
  type        = number
  description = "Port that expose the service in the target EC2 istances"
  default     = "80"
}

variable "asg_target_protocol" {
  type        = string
  description = "Protocol for the load balancer"
  default     = "HTTP"
}

variable "lb_type" {
  type        = string
  description = "Load balancer type [ application | network ]"
  default     = "application"
}

variable "lb_certificate_arn" {
  type        = string
  description = "Load balancer HTTPS listner certificate arn"
  default     = ""
}

variable "lb_enable_http_to_https_redirect" {
  type        = bool
  description = "If true enable an http listener that redirect the traffic to https"
  default     = false
}

## Load balancer healthcheck

variable "lb_heathcheck_enabled" {
  type        = bool
  description = "Enable or disable healtcheck"
  default     = true
}

variable "lb_heathcheck_interval" {
  type        = number
  description = "Healtcheck interval"
  default     = 30
}

variable "lb_heathcheck_path" {
  type        = string
  description = "Healtcheck target path"
  default     = "/"
}

variable "lb_heathcheck_healthy_threshold" {
  type        = number
  description = "Number of passed healthcheck for defining that an istance is healty"
  default     = 3
}

variable "lb_heathcheck_unhealthy_threshold" {
  type        = number
  description = "Number of failed healthcheck for defining that an istance is unhealty"
  default     = 2
}

variable "lb_heathcheck_matcher" {
  type        = string
  description = "Responces healthcheck has to match to define that the istance is responding correctly"
  default     = "200-399"
}
