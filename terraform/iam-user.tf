resource "aws_iam_user" "testuser" {
  name = "testuser"
}

resource "aws_iam_access_key" "testuser-key" {
  user = "${aws_iam_user.testuser.name}"
}

resource "aws_iam_user_policy" "rds_testuser_iam_auth_policy" {
  name = "rds_testuser_iam_auth-policy"
  user = "${aws_iam_user.testuser.name}"

  policy = <<EOF
{
   "Version": "2012-10-17",
   "Statement": [
      {
         "Effect": "Allow",
         "Action": [
             "rds-db:connect"
         ],
         "Resource": [
             "arn:aws:rds-db:::dbuser:microconf/testuser"
         ]
      }
   ]
}
EOF
}

output "user-secret" {
  value = "${aws_iam_access_key.testuser-key.secret}"
}

output "user-encrypted-secret" {
  value = "${aws_iam_access_key.testuser-key.encrypted_secret}"
}
