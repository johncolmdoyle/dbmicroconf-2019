variable "database_master_username" {
  description = "Superuser for Session Mgmr Demo Postgresql"
  default = "demouser"
  type    = "string"
}

variable "vpc_id" {
  description = "ID of microconf VPC"
  default     = "vpc-0805eb2f77b587315"
  type        = "string"
}

variable "vpc_private_subnet_ids" {
  description = "List of private subnet IDs"
  default     = ["subnet-0ba9d97724695681f","subnet-053dcc8050bbeef19","subnet-052dd8ebf3511d73f"]
  type        = "list"
}

variable "vpc_private_subnet_cidr_blocks" {
  description = "List of private subnet CIDR blocks"
  default     = ["10.0.1.0/24","10.0.2.0/24","10.0.3.0/24"]
  type        = "list"
}

