resource "aws_iam_role" "secrets_rotation_role" {
  name = "microconf_iam_auth_secrets_rotation_role"

  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": "sts:AssumeRole",
      "Principal": {
        "Service": "lambda.amazonaws.com"
      },
      "Effect": "Allow",
      "Sid": ""
    }
  ]
}
EOF
}


resource "aws_iam_policy_attachment" "secrets_rotation_basic_attach" {
  name       = "microconf_iam_auth_secrets_rotation_basic_attach"
  roles      = ["${aws_iam_role.secrets_rotation_role.name}"]
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole"
}

resource "aws_iam_policy" "secrets_rotation_policy" {
  name = "microconf_iam_auth_secrets_rotation_policy"
  path = "/"
  description = "IAM policy for microconf secrets rotation"

  policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": [
        "logs:CreateLogGroup",
        "logs:CreateLogStream",
        "logs:PutLogEvents",
        "ec2:CreateNetworkInterface",
        "ec2:DescribeNetworkInterfaces",
        "ec2:DeleteNetworkInterface",
        "secretsmanager:DescribeSecret",
        "secretsmanager:GetSecretValue",
        "secretsmanager:PutSecretValue",
        "secretsmanager:UpdateSecretVersionStage",
        "secretsmanager:GetRandomPassword"
      ],
      "Resource": "*",
      "Effect": "Allow"
    }
  ]
}
EOF
}

resource "aws_iam_policy_attachment" "secrets_rotation_policy_attach" {
  name       = "microconf_iam_auth_secrets_rotation_policy_attach"
  roles      = ["${aws_iam_role.secrets_rotation_role.name}"]
  policy_arn = "${aws_iam_policy.secrets_rotation_policy.arn}"
}

resource "aws_lambda_function" "secrets_rotation" {
  filename      = "secrets_rotation.zip"
  function_name = "microconf_iam_auth_secrets_rotation"
  role          = "${aws_iam_role.secrets_rotation_role.arn}"
  handler       = "lambda_function.lambda_handler"

  # The filebase64sha256() function is available in Terraform 0.11.12 and later
  # For Terraform 0.11.11 and earlier, use the base64sha256() function and the file() function:
  # source_code_hash = "${base64sha256(file("lambda_function_payload.zip"))}"
  source_code_hash = "${filebase64sha256("secrets_rotation.zip")}"

  runtime = "python2.7"

  environment {
    variables = {
      SECRETS_MANAGER_ENDPOINT = "https://secretsmanager.us-east-1.amazonaws.com"
    }
  }

  vpc_config {
    subnet_ids = ["${module.vpc.private_subnets[0]}", "${module.vpc.private_subnets[1]}", "${module.vpc.private_subnets[2]}"]
    security_group_ids = ["${module.postgres_sg.this_security_group_id}"]
  }
}

resource "aws_secretsmanager_secret" "microconf_secrets_manager" {
  name                = "microconf_iam_auth_db_user"
  rotation_lambda_arn = "${aws_lambda_function.secrets_rotation.arn}"

  rotation_rules {
    automatically_after_days = 7
  }
}

resource "aws_secretsmanager_secret_version" "microconf_secrets_manager_secret" {
  lifecycle {
    ignore_changes = [
      "secret_string"
    ]
  }
  secret_id     = "${aws_secretsmanager_secret.microconf_secrets_manager.id}"
  secret_string = <<EOF
{
  "username": "${module.db.this_db_instance_username}",
  "engine": "postgres",
  "dbname": "${module.db.this_db_instance_name}",
  "host": "${module.db.this_db_instance_address}",
  "password": "${module.db.this_db_instance_password}",
  "port": 5432,
  "dbInstanceIdentifier": "${module.db.this_db_instance_id}"
}
EOF
}

resource "aws_lambda_permission" "allow_secret_manager_call_Lambda" {
    function_name = "${aws_lambda_function.secrets_rotation.function_name}"
    statement_id = "AllowExecutionSecretManager"
    action = "lambda:InvokeFunction"
    principal = "secretsmanager.amazonaws.com"
}

