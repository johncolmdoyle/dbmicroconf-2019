variable "ssh_public_key_names" {
  description = "The name of the public keys saved in public_keys directory"
  default = ["johndoyle", "seconduser"]
  type    = "list"
}
