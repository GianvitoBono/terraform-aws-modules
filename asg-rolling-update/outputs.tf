output "alb_dns" {
  value = var.lb_type == "application" && var.lb_protocol == "HTTP" ? module.alb.this_lb_dns_name : module.alb_https.this_lb_dns_name
}

output "alb_arn" {
  value = var.lb_type == "application" && var.lb_protocol == "HTTP" ? module.alb.this_lb_arn : module.alb_https.this_lb_arn
}

output "istance_sg_id" {
  value = aws_security_group.istance_sg.id
}

output "loadbalancer_sg_id" {
  value = aws_security_group.loadbalancer_sg.id
}

output "cloudformation_stack_id" {
  value = aws_cloudformation_stack.this.id
}

output "cloudformation_stack_outputs" {
  value = aws_cloudformation_stack.this.outputs
}

output "launch_tamplate_id" {
  value = aws_launch_template.this.id
}

output "target_group_arn" {
  value = local.tg_arns
}