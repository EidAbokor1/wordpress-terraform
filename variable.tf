variable "aws_region" {
  default = "eu-west-2"
}

variable "db_password" {
  type      = string
  sensitive = true
}

variable "db_username" {
  type    = string
  default = "admin"
}