output "this_vpc_id" {
  description = "The ID of the microconf VPC"
  value       = "${module.vpc.vpc_id}"
}

output "this_vpc_public_subnet_ids" {
  description = "The IDs of the Public Subnets in the mircoconf VPC"
  value       = "${module.vpc.public_subnets}"
}

output "this_vpc_private_subnet_ids" {
  description = "The IDs of the Private Subnets in the mircoconf VPC"
  value       = "${module.vpc.private_subnets}"
}

output "this_vpc_public_subnet_cidrs" {
  description = "The CIDR blocks for the public subnets in the microconf VPC"
  value       = "${module.vpc.public_subnets_cidr_blocks}"
}

output "this_vpc_private_subnet_cidrs" {
  description = "The CIDR blocks for the private subnets in the microconf VPC"
  value       = "${module.vpc.private_subnets_cidr_blocks}"
}
