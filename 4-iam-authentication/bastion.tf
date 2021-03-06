module "ec2" {
  source = "terraform-aws-modules/ec2-instance/aws"

  name                        = "bastion-iam-host"
  instance_count              = 1

  ami                         = "ami-0b69ea66ff7391e80"
  instance_type               = "t2.micro"
  subnet_id                   = "${var.vpc_public_subnet_ids[0]}"
  vpc_security_group_ids      = ["${module.bastion_iam_sg.this_security_group_id}"]
  associate_public_ip_address = true
  monitoring                  = false 
  iam_instance_profile        = "${aws_iam_instance_profile.iam_s3_readonly.name}"

  user_data = <<-EOF
              #!/bin/bash
              yum update -y
              mkdir ~/users_public_keys
              aws s3 sync s3://silbo-bastion-iam-public-keys/ ~/users_public_keys
              cat ~/users_public_keys/* > home/ec2-user/.ssh/authorized_keys
              EOF

  tags = {
    Name       = "microconf-iam-authentication"
    Event      = "microconf"
  }
}

module "bastion_iam_sg" {
  source = "terraform-aws-modules/security-group/aws"
  version = "~> 3.0"

  name        = "bastion-iam-sg"
  description = "Security group for Bastion and IAM Authentication"
  vpc_id      = "${var.vpc_id}"

  ingress_cidr_blocks = ["0.0.0.0/0"]
  ingress_rules       = ["ssh-tcp"]
  egress_rules        = ["all-all"]
}

# This is just a sample definition of IAM instance profile which is allowed to read-only from S3.
resource "aws_iam_instance_profile" "iam_s3_readonly" {
  name = "microconf_iam_s3_readonly"
  role = "${aws_iam_role.iam_s3_readonly.name}"
}

resource "aws_iam_role" "iam_s3_readonly" {
  name = "microconf_iam_s3_readonly"
  path = "/"

  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Sid": "",
      "Effect": "Allow",
      "Principal": {
        "Service": "ec2.amazonaws.com"
      },
      "Action": "sts:AssumeRole"
    }
  ]
}
EOF
}

resource "aws_iam_role_policy" "iam_s3_readonly_policy" {
  name = "microconf_iam_s3_readonly-policy"
  role = "${aws_iam_role.iam_s3_readonly.id}"

  policy = <<EOF
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Sid": "Stmt1425916919000",
            "Effect": "Allow",
            "Action": [
                "s3:List*",
                "s3:Get*"
            ],
            "Resource": ["arn:aws:s3:::silbo-bastion-iam-public-keys","arn:aws:s3:::silbo-bastion-iam-public-keys/*"]
        }
    ]
}
EOF
}
