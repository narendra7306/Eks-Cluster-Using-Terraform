variable "subnet_id_1" {
  #type = string
  default = ["aws_subnet.demo-pub1.id", "aws_subnet.demo-pub2.id"]
 }
 
 variable "subnet_id_2" {
  #type = string
  default = "aws_subnet.demo-pub2.id"
 }

 variable "sg_id" {
  #type = string
  default = "aws_security_group.allow_Web-SSH.id"
 } 

 