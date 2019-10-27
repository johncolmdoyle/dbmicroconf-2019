#####
# DB
#####
module "db" {
  source = "github.com/terraform-aws-modules/terraform-aws-rds"

  identifier = "microconf"

  engine            = "postgres"
  engine_version    = "10.6"
  instance_class    = "db.t2.micro"
  allocated_storage = 5
  storage_encrypted = false

  name = "microconfdb"

  username = "${var.database_master_username}"
  password = "${random_password.password.result}"
  port     = "5432"

  iam_database_authentication_enabled = true

  vpc_security_group_ids = ["${module.postgres_sg.this_security_group_id}"]

  maintenance_window = "Mon:00:00-Mon:03:00"
  backup_window      = "03:00-06:00"

  backup_retention_period = 0

  tags = {
    Event       = "microconf"
  }

  # DB subnet group
  subnet_ids = ["${module.vpc.private_subnets[0]}", "${module.vpc.private_subnets[1]}", "${module.vpc.private_subnets[2]}"]

  # DB parameter group
  family = "postgres10"

  # Snapshot name upon DB deletion
  final_snapshot_identifier = "microconfdb"
}

module "postgres_sg" {
  source = "terraform-aws-modules/security-group/aws"
  version = "~> 3.0"

  name        = "postgres-sg"
  description = "Security group for Postgres Database"
  vpc_id      = "${module.vpc.vpc_id}"

  # Access from the public subnets for the App and Bastion Instance
  # Access from the private subnets to allow secret's rotation
  ingress_cidr_blocks = ["${module.vpc.public_subnets_cidr_blocks[0]}", "${module.vpc.public_subnets_cidr_blocks[1]}", "${module.vpc.public_subnets_cidr_blocks[2]}","${module.vpc.private_subnets_cidr_blocks[0]}", "${module.vpc.private_subnets_cidr_blocks[1]}", "${module.vpc.private_subnets_cidr_blocks[2]}"]
  ingress_rules       = ["postgresql-tcp"]
  egress_rules        = ["all-all"]
}

resource "random_password" "password" {
  length = 16
  special = true
  override_special = "_%@"
}
