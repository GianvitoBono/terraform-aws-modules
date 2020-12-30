variable "app_name" {
  type        = string
  description = "Application name. This would be used to name all the VPC resources"
}

variable "cidr_block" {
  type        = string
  description = "VPC CIDR block"
}

variable "subnets" {
  type = list(object({
    cidr            = string
    is_private      = bool
    name            = string
    tf_res_id       = string
    auto_assing_pip = bool
  }))
  description = "List all the desired subnets"
}

variable "multi_az_nat" {
  type        = bool
  description = "If set to true will create a reduntant NAT Gateway and separates the private subnets between the two (default to false)"
  default     = false
}

variable "env" {
  type        = string
  description = "Env label, default is prod"
  default     = "prod"
}