variable "subnet_id" {
  type        = string
}

variable "security_group_id" {
  type        = string
}

variable "iam_instance_profile" {
  type = string
}

variable "rds_endpoint" {
  type = string
}

variable "db_password" {
  type      = string
  sensitive = true
}

variable "db_username" {
  type    = string
  default = "admin"
}