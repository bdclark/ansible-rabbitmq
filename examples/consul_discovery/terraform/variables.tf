variable "key_name" {
  description = "Name of AWS key pair to use"
}

variable "private_key_path" {
  description = "Path to PEM encoded private key"
}

variable "subnet_id" {
  description = "The VPC Subnet ID to launch in"
}
