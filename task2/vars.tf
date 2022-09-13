# Keypair
variable "instance_keypair" {
  type = string
  default = "homework_ian"
}

# AZs
variable "az_list" {
  type = map
  default = {
    "1" = "us-east-1a",
    "2" = "us-east-1b",
  }
}
