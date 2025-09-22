data "aws_caller_identity" "current" {}


#vpc
resource "aws_vpc" "main_vpc" {
    cidr_block = var.vpc_cidr_block
    enable_dns_support = true
    enable_dns_hostname = true
    tags = {
        "Name" = "${var.project_name}-vpc"
        "Environment" = "${var.environment}"
        "CreatedBy" = "Terraform"
    }
}

#internet gateway
resource "aws_internet_gateway" "main_igw" {
    vpc_id = aws_vpc.main_vpc.id

    tags = {
        "Name" = "${var.project_name}-igw"
        "Environment" = "${var.environment}"
        "CreatedBy" = "Terraform"
    }
}

#subnets
resource "aws_subnet" "private_zone1" {
    vpc_id       = aws_vpc.main_vpc.id
    cidr_block   = "10.0.0.0/19"
    availability_zone = local.zone1

    tags = {
        "Name"                                                         = "${var.environment}-private-${local.zone1}"
        "Environment"                                                  = "${var.environment}"
        "kubernetes.io/role/internal-elb"                              = "1"
        "kubernetes.io/cluster/${var.environment}-${var.project_name}" = owned
    }
}

resource "aws_subnet" "private_zone2" {
    vpc_id       = aws_vpc.main_vpc.id
    cidr_block   = "10.0.32.0/19"
    availability_zone = local.zone2

    tags = {
        "Name"                                                         = "${var.environment}-private-${local.zone2}"
        "Environment"                                                  = "${var.environment}"
        "kubernetes.io/role/internal-elb"                              = "1"
        "kubernetes.io/cluster/${var.environment}-${var.project_name}" = owned
    }
}

resource "aws_subnet" "public_zone1" {
    vpc_id                  = aws_vpc.main_vpc.id
    cidr_block              = "10.0.64.0/19"
    availability_zone       = local.zone1
    map_public_ip_on_launch = true
    
    tags = {
        "Name"                                                         = "${var.environment}-public-${local.zone1}"
        "kubernetes.io/role/elb"                                       = "1"
        "kubernetes.io/cluster/${var.environment}-${var.project_name}" = owned
    }
}

resource "aws_subnet" "public_zone2" {
    vpc_id                  = aws_vpc.main_vpc.id
    cidr_block              = "10.0.96.0/19"
    availability_zone       = local.zone1
    map_public_ip_on_launch = true
    
    tags = {
        "Name"                                                         = "${var.environment}-public-${local.zone2}"
        "kubernetes.io/role/elb"                                       = "1"
        "kubernetes.io/cluster/${var.environment}-${var.project_name}" = owned
    }
}

#eip 
resource "aws_eip" "nat" {
    domain = "vpc"

    tags = {
        Name = "${var.environment}-nat"
    }
}

#natgw
resource "aws_nat_gateway" "main_vpc_nat" {
    allocation_id = aws_eip.nat.id
    subnet_id     = aws_subnet.public_zone1.id

    tags = {
        Name = "${var.environment}-nat"
    }
    depends_on = [aws_internet_gateway.main_igw]
}

#routetb
resource "aws_route_table" "private" {
  vpc_id = aws_vpc.main_vpc.id

  route {
    cidr_block     = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.main_vpc_nat.id
  }

  tags = {
    Name = "${var.environment}-private"
  }
}

resource "aws_route_table" "public" {
  vpc_id = aws_vpc.main_vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.main_igw.id
  }

  tags = {
    Name = "${var.environment}-public"
  }
}

resource "aws_route_table_association" "private_zone1" {
  subnet_id      = aws_subnet.private_zone1.id
  route_table_id = aws_route_table.private.id
}

resource "aws_route_table_association" "private_zone2" {
  subnet_id      = aws_subnet.private_zone2.id
  route_table_id = aws_route_table.private.id
}

resource "aws_route_table_association" "public_zone1" {
  subnet_id      = aws_subnet.public_zone1.id
  route_table_id = aws_route_table.public.id
}

resource "aws_route_table_association" "public_zone2" {
  subnet_id      = aws_subnet.public_zone2.id
  route_table_id = aws_route_table.public.id
}