provider "aws" {
  region = "us-east-1"
}

resource "aws_instance" "demo-server" {
    ami = "ami-0fc5d935ebf8bc3bc"
    instance_type = "t2.micro"
    key_name = "dpp"
    //security_groups = [ "demo-sg" ]
    vpc_security_group_ids = [aws_security_group.demo-sg.id]
    subnet_id = aws_subnet.dpp-public_subent_01.id
    for_each = toset(["jenkins-master", "build-slave", "ansible"])
   tags = {
     Name = "${each.key}"
   }
}

resource "aws_security_group" "demo-sg" {
  name        = "demo-sg"
  description = "SSH Access"
  vpc_id =  aws_vpc.dpp-vpc.id
  
  ingress {
    description      = "Ssh access"
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
    Name = "ssh-port"

  }
}
    #create a vpc
resource "aws_vpc" "dpp-vpc" {
       cidr_block = "10.1.0.0/16"
       tags = {
        Name = "dpp-vpc"
     }
   }

   //Create Subnets 
resource "aws_subnet" "dpp-public_subent_01" {
    vpc_id = aws_vpc.dpp-vpc.id
    cidr_block = "10.1.1.0/24"
    map_public_ip_on_launch = "true"
    availability_zone = "us-east-1a"
    tags = {
      Name = "dpp-public_subent_01"
    }
}

resource "aws_subnet" "dpp-public_subent_02" {
    vpc_id = aws_vpc.dpp-vpc.id
    cidr_block = "10.1.2.0/24"
    map_public_ip_on_launch = "true"
    availability_zone = "us-east-1b"
    tags = {
      Name = "dpp-public_subent_02"
    }
}

    #Creating an Internet Gateway 
resource "aws_internet_gateway" "dpp-igw" {
    vpc_id = aws_vpc.dpp-vpc.id
    tags = {
      Name = "dpp-igw"
    }
}

// Create a route table 
resource "aws_route_table" "dpp-public-rt" {
    vpc_id = aws_vpc.dpp-vpc.id
    route {
        cidr_block = "0.0.0.0/0"
        gateway_id = aws_internet_gateway.dpp-igw.id
    }
    tags = {
      Name = "dpp-public-rt"
    }
}

// Associate subnet with route table

resource "aws_route_table_association" "dpp-rta-public-subent-01" {
    subnet_id = aws_subnet.dpp-public_subent_01.id
    route_table_id = aws_route_table.dpp-public-rt.id
}

resource "aws_route_table_association" "dpp-rta-public-subent-02" {
    subnet_id = aws_subnet.dpp-public_subent_02.id
    route_table_id = aws_route_table.dpp-public-rt.id
}