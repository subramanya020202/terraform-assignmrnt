variable "ami_id" {
  description = "AMI ID to use for EC2 instances"
  default     = "ami-0b0ea68c435eb488d" 
}

variable "public_key_path" {
  description = "Path to your SSH public key"
  default     = "~/.ssh/id_rsa.pub"
}

variable "instance_type" {
  default = "t2.micro"
}
