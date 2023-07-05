# Configure the AWS provider
provider "aws" {
  region = "us-east-1"
}

# Create a VPC
resource "aws_vpc" "my_vpc" {
  cidr_block = "10.0.0.0/16"
     tags = {
        Name = "my_vpc"
    }
}

# Create a public subnet
resource "aws_subnet" "my_subnet" {
  vpc_id                  = aws_vpc.my_vpc.id
  cidr_block              = "10.0.0.0/24"  
  map_public_ip_on_launch = true
     tags = {
        Name = "my_subnet"
    }
}

# Create an internet gateway
resource "aws_internet_gateway" "my_igw" {
  vpc_id = aws_vpc.my_vpc.id
    tags = {
    Name = "my_igw"
  }
}

# Create a route table
resource "aws_route_table" "my_route_table" {
  vpc_id = aws_vpc.my_vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.my_igw.id
  }
   tags = {
    Name = "my_route_table"
  }
}

# Associate the route table with the public subnet
resource "aws_route_table_association" "my_route_table_association" {
  subnet_id      = aws_subnet.my_subnet.id
  route_table_id = aws_route_table.my_route_table.id
}

# Create a security group
resource "aws_security_group" "my_security_group" {
  name        = "my_security_group"
  description = "Allow HTTP and SSH traffic"

  vpc_id = aws_vpc.my_vpc.id

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
   tags = {
    Name = "my_security_group"
  }
}
#data "aws_ami" "ubuntu" {
 # most_recent = true

 # filter {
  #  name   = "name"
   # values = ["ubuntu/images/hvm-ssd/ubuntu-focal-20.04-amd64-server-*"]
  #}

 # filter {
  #  name   = "virtualization-type"
  #  values = ["hvm"]
  #}

  #owners = ["099720109477"] # Canonical
#}

resource "aws_instance" "my_ec2_instance" {
    ami = "ami-053b0d53c279acc90"
    # this if i use filter but i used ami to insure that is free tier 
    # data.aws_ami.ubuntu.id
    instance_type = "t2.micro"
    #associate_public_ip_address = true
    subnet_id = aws_subnet.my_subnet.id
    vpc_security_group_ids = [aws_security_group.my_security_group.id]
    user_data = <<EOF
    #!/bin/bash
    sudo apt-get update
    sudo apt-get install -y apache2
    sudo systemctl start apache2
    sudo systemctl enable apache2
    EOF

  tags = {
    Name = "my_ec2_instance"
  }
}
