# VPC

resource "aws_vpc" "wireguard_vpc" {
  cidr_block           = "10.0.0.0/16"
  enable_dns_support   = true
  enable_dns_hostnames = true
  tags = {
    Name = "wireguard-vpc"
  }
}

resource "aws_subnet" "wireguard_public_subnet" {
  vpc_id                  = aws_vpc.wireguard_vpc.id
  cidr_block              = "10.0.1.0/24"
  availability_zone       = "us-east-1a"
  map_public_ip_on_launch = true
  tags = {
    Name = "wireguard-public-subnet"
  }
}


resource "aws_subnet" "http_server_private_subnet" {
  vpc_id            = aws_vpc.wireguard_vpc.id
  cidr_block        = "10.0.100.0/24"
  availability_zone = "us-east-1a"
  tags = {
    Name = "http-server-private-subnet"
  }
}

resource "aws_internet_gateway" "wireguard_igw" {
  vpc_id = aws_vpc.wireguard_vpc.id
}

resource "aws_eip" "wireguard_public_ip" {
  instance = aws_instance.ec2_wireguard.id
}

resource "aws_eip" "nat_public_ip" {
}

resource "aws_nat_gateway" "private_subnet_natgw" {
  subnet_id     = aws_subnet.wireguard_public_subnet.id
  allocation_id = aws_eip.nat_public_ip.id
  tags = {
    Name = "private-subnet-natgw"
  }
}

resource "aws_security_group" "wireguard_sg" {
  name_prefix = "wireguard_sg"

  lifecycle {
    create_before_destroy = true
  }

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 51820
    to_port     = 51820
    protocol    = "udp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  vpc_id = aws_vpc.wireguard_vpc.id
}

resource "aws_security_group" "http_server_sg" {
  name_prefix = "http_sg"

  lifecycle {
    create_before_destroy = true
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  vpc_id = aws_vpc.wireguard_vpc.id
}

resource "aws_vpc_security_group_ingress_rule" "http_from_wireguard" {
  from_port                    = 80
  to_port                      = 80
  ip_protocol                  = "tcp"
  referenced_security_group_id = aws_security_group.wireguard_sg.id
  security_group_id            = aws_security_group.http_server_sg.id
}

resource "aws_vpc_security_group_ingress_rule" "ssh_from_wireguard" {
  from_port                    = 22
  to_port                      = 22
  ip_protocol                  = "tcp"
  referenced_security_group_id = aws_security_group.wireguard_sg.id
  security_group_id            = aws_security_group.http_server_sg.id
}

resource "aws_vpc_security_group_ingress_rule" "icmp_from_wireguard" {
  from_port                    = -1
  to_port                      = -1
  ip_protocol                  = "icmp"
  referenced_security_group_id = aws_security_group.wireguard_sg.id
  security_group_id            = aws_security_group.http_server_sg.id
}

# PUBLIC ROUTE TABLE

resource "aws_route_table" "public_route_table" {
  vpc_id = aws_vpc.wireguard_vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.wireguard_igw.id
  }

  tags = {
    Name = "public-route-table"
  }
}

resource "aws_route_table_association" "wireguard_public_subnet_association" {
  subnet_id      = aws_subnet.wireguard_public_subnet.id
  route_table_id = aws_route_table.public_route_table.id
}

# PRIVATE ROUTE TABLE

resource "aws_route_table" "private_route_table" {
  vpc_id = aws_vpc.wireguard_vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_nat_gateway.private_subnet_natgw.id
  }

  tags = {
    Name = "private-route-table"
  }
}

resource "aws_route_table_association" "http_server_private_subnet_association" {
  subnet_id      = aws_subnet.http_server_private_subnet.id
  route_table_id = aws_route_table.private_route_table.id
}

# EC2 INSTANCES AND KEYS

resource "aws_key_pair" "wireguard_key_pair" {
  key_name   = "wireguard-key-pair"
  public_key = tls_private_key.rsa.public_key_openssh
}

resource "tls_private_key" "rsa" {
  algorithm = "RSA"
  rsa_bits  = 4096
}

resource "local_file" "tf-key" {
  content  = tls_private_key.rsa.private_key_pem
  filename = "wireguard-key-pair"
}

resource "null_resource" "change_key_permissions" {
  depends_on = [local_file.tf-key]

  provisioner "local-exec" {
    command = "chmod 600 ${local_file.tf-key.filename}"
  }
}

resource "aws_instance" "ec2_wireguard" {
  ami           = "ami-07d9b9ddc6cd8dd30"
  instance_type = "t2.micro"
  key_name      = aws_key_pair.wireguard_key_pair.key_name
  subnet_id     = aws_subnet.wireguard_public_subnet.id
  vpc_security_group_ids = [
    aws_security_group.wireguard_sg.id
  ]
  tags = {
    Name = "wireguard-ec2"
  }
}

resource "aws_instance" "ec2_http" {
  ami           = "ami-0440d3b780d96b29d"
  instance_type = "t2.micro"
  key_name      = aws_key_pair.wireguard_key_pair.key_name
  subnet_id     = aws_subnet.http_server_private_subnet.id
  vpc_security_group_ids = [
    aws_security_group.http_server_sg.id
  ]
  tags = {
    Name = "http-server-ec2"
  }
  user_data = file("scripts/http-init-script.sh")
}