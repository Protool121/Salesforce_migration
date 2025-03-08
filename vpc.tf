
#  Networking setup

resource "aws_vpc" "runner" {
  cidr_block       = "10.0.0.0/16"
  instance_tenancy = "default"

  tags = {
    Name = "runner-vpc"
  }
}

# Networking Privsate subnet
resource "aws_subnet" "private-runner" {
  vpc_id     = aws_vpc.runner.id
  cidr_block = "10.0.1.0/24"

  tags = {
    Name = "private-runner"
  }
}

# Networking Public subnet

resource "aws_subnet" "public-runner" {
  vpc_id     = aws_vpc.runner.id
  cidr_block = "10.0.7.0/24"

  tags = {
    Name = "public-runner"
  }
}

# Networking Internet Gateway for public subnet

resource "aws_internet_gateway" "runnergw" {
  vpc_id = aws_vpc.runner.id

  tags = {
    Name = "runner-igw"
  }
}

# Networking Public subnet route table

resource "aws_route_table" "public-route-table" {
  vpc_id = aws_vpc.runner.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.runnergw.id
  }

  tags = {
    Name = "public-route-table"
  }
}

# Networking Privsate subnet route table

resource "aws_route_table" "private-route-table" {
  vpc_id = aws_vpc.runner.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.runnergw.id
  }

  tags = {
    Name = "private-route-table"
  }
}


# resource "aws_route_table_association" "private" {
#   subnet_id      = aws_subnet.private-runner.id
#   route_table_id = aws_route_table.private-route-table.id
# }


# Networking Privsate subnet

resource "aws_route_table_association" "public" {
  subnet_id      = aws_subnet.public-runner.id
  route_table_id = aws_route_table.public-route-table.id
}


resource "aws_security_group" "runnersg" {
  name        = "runner-sg"
  description = "inbound incoming"
  vpc_id      = aws_vpc.runner.id
  tags = {
    Name = "runner-sg"
  }
}



# data "local_file" "user_data" {
#   filename = "./file.sh"
# }


resource "aws_instance" "runner-ec2-public" {
  ami                         = "ami-03a725ae7d906005d"
  instance_type               = "t2.micro"
  subnet_id                   = aws_subnet.public-runner.id
  associate_public_ip_address = true


  user_data = <<-EOF
    #!/bin/bash
    yum update -y
    yum install -y httpd
    systemctl start httpd
    systemctl enable httpd
    EC2_AVAIL_ZONE=$(curl -s http://169.254.169.254/latest/meta-data/placement/availability-zone)
    echo "Hello World from $(hostname -f) in AZ $EC2_AVAIL_ZONE " > /var/www/html/index.html
EOF
  # }
  tags = {
    Name = "runner-ec2-public"
  }
}


resource "aws_instance" "runner-ec2-private" {
  ami                         = "ami-03a725ae7d906005d"
  instance_type               = "t2.micro"
  subnet_id                   = aws_subnet.private-runner.id
  associate_public_ip_address = true


  user_data = <<-EOF
    #!/bin/bash
    yum update -y
    yum install -y httpd
    systemctl start httpd
    systemctl enable httpd
    EC2_AVAIL_ZONE=$(curl -s http://169.254.169.254/latest/meta-data/placement/availability-zone)
    echo "Hello World from $(hostname -f) in AZ $EC2_AVAIL_ZONE " > /var/www/html/index.html
EOF
  # }
  tags = {
    Name = "runner-ec2-private"
  }
}


resource "aws_security_group" "runner-ec2-public-sg" {
  name        = "runner-ec2-public-ingress-rule"
  description = "runner-ec2-public-ingress-rule"
  vpc_id      = aws_vpc.runner.id
  tags = {
    Name = "runner-ec2-public-sg"
  }
}

resource "aws_vpc_security_group_ingress_rule" "ingress-sg-ec2" {
  security_group_id = aws_security_group.runner-ec2-public-sg.id

  cidr_ipv4   = "0.0.0.0/0"
  from_port   = 80
  ip_protocol = "tcp"
  to_port     = 80

  tags = {
    Name = "ingress-sg-ec2"
  }
}

# resource "aws_vpc_security_group_ingress_rule" "allow_tls_ipv4" {
#   security_group_id = aws_security_group.allow_tls.id
#   cidr_ipv4         = aws_vpc.runner.id
#   from_port         = 80
#   ip_protocol       = "tcp"
#   to_port           = 80
# }



