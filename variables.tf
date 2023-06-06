variable "region" {
  default = "us-east-1"
}

variable "ami" {
  default = "ami-0eae0940d45f46876"
}

variable "instance-type" {
  default = "t3.micro"
}

variable "keypair-name" {
  default = "devops-keypair"
}

variable "subnet_counts" {
  default = 3
}

variable "asg-min" {
  default = 0
}

variable "instance-name" {
  default = "portfolio"
}

variable "authorized-ssh-ip" {}
