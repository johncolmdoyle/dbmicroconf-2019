resource "aws_s3_bucket" "ssh_public_keys" {
  bucket = "silbo-bastion-sm-public-keys"
  acl    = "private"

  tags = {
    Name       = "microconf-secrets-manager"
    Event      = "microconf"
  }
}

resource "aws_s3_bucket_object" "ssh_public_keys" {
  bucket = "${aws_s3_bucket.ssh_public_keys.bucket}"
  key    = "${element(var.ssh_public_key_names, count.index)}.pub"

  # Make sure that you put files into correct location and name them accordingly (`public_keys/{keyname}.pub`)
  source = "public_keys/${element(var.ssh_public_key_names, count.index)}.pub"
  count  = "${length(var.ssh_public_key_names)}"

  depends_on = ["aws_s3_bucket.ssh_public_keys"]
}
