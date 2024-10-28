variable "cidr_vpc" {
  default = "192.168.0.0/16"
}

variable "vpc_name" {
  default = "Test-VPC"
}

variable "cidr_subnet1" {
  default = "192.168.10.0/24"
}

variable "cidr_subnet2" {
  default = "192.168.12.0/24"
}

variable "availability_zone_name1" {
    default = "us-east-1a"  
}

variable "availability_zone_name2" {
    default = "us-east-1b"  
}

variable "subnet_name1" {
  default = "Pub-Subnet1"
}

variable "subnet_name2" {
  default = "Pub-Subnet2"
}

 