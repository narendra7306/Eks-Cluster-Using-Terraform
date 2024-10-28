provider "aws" {
  region     = "us-east-1"
  profile    = "seelam"
}


# maintain remotely terraform state file in s3
terraform {
  backend "s3" {
    bucket = "srreddy-terraform-state"
    key    = "eks/terraform.tf"
    region = "us-east-1"
  }
}


# Create VPC
resource "aws_vpc" "demo-vpc" {
  cidr_block       = "${var.cidr_vpc}"
  instance_tenancy = "default"

  tags = {
    Name = "${var.vpc_name}"
  }
}

# Create Subnet in the VPC

resource "aws_subnet" "demo-pub1" {
  vpc_id     = aws_vpc.demo-vpc.id
  cidr_block = "${var.cidr_subnet1}"
  availability_zone = "us-east-1a"
  map_public_ip_on_launch = true
  
  tags = {
    Name = "${var.subnet_name1}"
  }
}

resource "aws_subnet" "demo-pub2" {
  vpc_id     = aws_vpc.demo-vpc.id
  cidr_block = "${var.cidr_subnet2}"
  availability_zone = "us-east-1b"
  map_public_ip_on_launch = true
  
  tags = {
    Name = "${var.subnet_name2}"
  }
}

# Create Internet Gateway For Demo-VPC 

resource "aws_internet_gateway" "demo-Igw" {
  vpc_id = aws_vpc.demo-vpc.id

  tags = {
    Name = "Demo-Igw"
  }
}


# Create Route Table 
resource "aws_route_table" "demo-rt" {
  vpc_id = aws_vpc.demo-vpc.id
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.demo-Igw.id
  }

  tags = {
    Name = "Demo-RWT"
  }
}


# Route Table Association 

resource "aws_route_table_association" "a" {
  subnet_id      = aws_subnet.demo-pub1.id
  route_table_id = aws_route_table.demo-rt.id
}

resource "aws_route_table_association" "b" {
  subnet_id      = aws_subnet.demo-pub2.id
  route_table_id = aws_route_table.demo-rt.id
}


# Create Sequrity Group to Allow 22, 80, 8080 and 443 port numbers

resource "aws_security_group" "allow_Web-SSH" {
  name        = "allow_tls"
  description = "Allow TLS inbound traffic"
  vpc_id      = aws_vpc.demo-vpc.id

  ingress {
    description      = "HTTPS from VPC"
    from_port        = 443
    to_port          = 443
    protocol         = "tcp"
    cidr_blocks      = ["0.0.0.0/0"]
    
  }

  ingress {
    description      = "HTTP from VPC"
    from_port        = 80
    to_port          = 80
    protocol         = "tcp"
    cidr_blocks      = ["0.0.0.0/0"]
    
  }

  ingress {
    description      = "SSH from VPC"
    from_port        = 22
    to_port          = 22
    protocol         = "tcp"
    cidr_blocks      = ["0.0.0.0/0"]
    
  }

  egress {
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }

  tags = {
    Name = "Terraform_SG"
  }
}


module "srreddy" {
    source = "./modules/eks-module"
    #vpc_id = aws_vpc.demo-vpc.id
    subnet_id_1 = aws_subnet.demo-pub1.id 
    subnet_id_2 = aws_subnet.demo-pub2.id
}
