# DB instance
output "this_db_instance_address" {
  description = "The address of the RDS instance"
  value       = "${module.db.this_db_instance_address}"
}

output "this_db_instance_name" {
  description = "The database name"
  value       = "${module.db.this_db_instance_name}"
}

output "this_db_instance_username" {
  description = "The master username for the database"
  value       = "${module.db.this_db_instance_username}"
}

output "this_db_instance_password" {
  description = "The database password (this password may be old, because Terraform doesn't track it after initial creation)"
  value       = "${module.db.this_db_instance_password}"
}

output "bastion_public_ip" {
  value = "${module.ec2.public_ip}"
}
