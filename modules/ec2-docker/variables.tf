variable "project_name" { type = string }
variable "vpc_id" { type = string }
variable "public_subnet_ids" { type = list(string) }
variable "private_subnet_ids" { type = list(string) }
variable "web_sg_id" { type = string }
variable "app_sg_id" { type = string }
variable "alb_target_group_arn" { type = string }