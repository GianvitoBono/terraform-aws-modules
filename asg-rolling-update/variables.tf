variable "app_name" {
  type        = string
  description = "Application name and tag, this will be used to name resources"
}

variable "ami_name_prefix" {
  type        = string
  description = "This will be used as a filter to choose the AMI for the lauch template"
}

variable "private_subnets_ids" {
  type        = list(string)
  description = "List of private subnets ids where the application shoud run"
}

variable "public_subnets_ids" {
  type        = list(string)
  description = "List of public subnets ids where the load balancer shoud run"
}

variable "vpc_id" {
  type        = string
  description = "VPC id where the resources will be deployed"
}

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

variable "key_name" {
  type        = string
  description = "Key name used for the EC2 istances"
}

variable "aws_region" {
  type        = string
  description = "AWS Region where all the resources will be created"
}

variable "env" {
  type        = string
  description = "Enviroment name (prod, dev, stage) default is prod, used for tags"
  default     = "prod"
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

variable "ec2_user_data" {
  type        = string
  description = "EC2 user data to add to the lauch group, default = empty"
  default     = ""
}

variable "instance_type_override" {
  type        = list(string)
  description = "List of EC2 instance types to overwrite on launch_configuration"
  default     = []
}

variable "instance_type" {
  type        = string
  description = "Default EC2 instance type to be used in the launch_configuration"
  default     = "t2.micro"
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