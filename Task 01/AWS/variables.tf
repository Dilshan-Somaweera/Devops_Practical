variable "aws_region" {
  default = "ap-south-1"
}

variable "vpc_cidr" {
  default = "10.0.0.0/16"
}

variable "public_subnet_cidrs" {
  type    = list(string)
  default = ["10.0.1.0/24", "10.0.2.0/24"]
}

variable "private_subnet_cidrs" {
  type    = list(string)
  default = ["10.0.3.0/24", "10.0.4.0/24"]
}

variable "azs" {
  type    = list(string)
  default = ["ap-south-1a", "ap-south-1b"]
}

variable "ami_id" {
  default = "ami-062f0cc54dbfd8ef1"
}

variable "key_pair" {
  default = "EC2_key"
}

variable "my_ip" {
  default = "0.0.0.0/0"
}

variable "db_username" {
  default = "admin"
}

variable "db_password" {
  default = "admin123$"
}
