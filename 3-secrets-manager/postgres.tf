module "db" {
  source = "github.com/terraform-aws-modules/terraform-aws-rds"

  identifier = "microconf-secrets-manager"

  engine            = "postgres"
  engine_version    = "10.6"
  instance_class    = "db.t2.micro"
  allocated_storage = 5
  storage_encrypted = false

  name = "microconfdb"

  username = "${var.database_master_username}"
  password = "${random_password.password.result}"
  port     = "5432"

  iam_database_authentication_enabled = false

  vpc_security_group_ids = ["${module.postgres_sg.this_security_group_id}"]

  maintenance_window = "Mon:00:00-Mon:03:00"
  backup_window      = "03:00-06:00"

  backup_retention_period = 0

  tags = {
    Name       = "microconf-secrets-manager"
    Event      = "microconf"
  }

  # DB subnet group
  subnet_ids = ["${var.vpc_private_subnet_ids[0]}", "${var.vpc_private_subnet_ids[1]}", "${var.vpc_private_subnet_ids[2]}"]

  # DB parameter group
  family = "postgres10"

  # Snapshot name upon DB deletion
  final_snapshot_identifier = "microconfdb-secrets-manager"
}

module "postgres_sg" {
  source = "terraform-aws-modules/security-group/aws"
  version = "~> 3.0"

  name        = "postgres-sg"
  description = "Security group for Postgres Database with secrets maanger"
  vpc_id      = "${var.vpc_id}"

  # Access from the public subnets for the App and Bastion Instance
  # Access from the private subnets to allow secret's rotation
  ingress_cidr_blocks = ["${var.vpc_public_subnet_cidr_blocks[0]}", "${var.vpc_public_subnet_cidr_blocks[1]}", "${var.vpc_public_subnet_cidr_blocks[2]}","${var.vpc_private_subnet_cidr_blocks[0]}", "${var.vpc_private_subnet_cidr_blocks[1]}", "${var.vpc_private_subnet_cidr_blocks[2]}"]
  ingress_rules       = ["postgresql-tcp"]
  egress_rules        = ["all-all"]
}

resource "random_password" "password" {
  length = 16
  special = false
}
