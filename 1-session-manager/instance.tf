module "ec2" {
  source = "terraform-aws-modules/ec2-instance/aws"

  name                        = "microdbconf-session-mgmr-instance"
  instance_count              = 1

  ami                         = "ami-0b69ea66ff7391e80"
  instance_type               = "t2.micro"
  subnet_id                   = "${var.vpc_private_subnet_ids[0]}"
  vpc_security_group_ids      = ["${module.session_mgmr_instance_sg.this_security_group_id}"]
  associate_public_ip_address = false
  monitoring                  = false 

  user_data = <<-EOF
              #!/bin/bash
              yum update -y
              yum install -y postgresql postgresql-server postgresql-devel postgresql-contrib postgresql-docs
              EOF

  tags = {
    Name       = "microconf-session-manager"
    Event      = "microconf"
  }
}

module "session_mgmr_instance_sg" {
  source = "terraform-aws-modules/security-group/aws"
  version = "~> 3.0"

  name        = "session-mgmr-instance-sg"
  description = "Security group for Session Manager Instance"
  vpc_id      = "${var.vpc_id}"

  ingress_cidr_blocks = ["0.0.0.0/0"]
  ingress_rules       = ["ssh-tcp"]
  egress_rules        = ["all-all"]
}
