data "aws_caller_identity" "current" {}

locals {
    nat_ip_cidr = [ for eip in aws_eip.main_vpc_nat_eip: ${eip.public_ip}/32 ]
    account_id = data.aws_caller_identity.current.account_id
}

#vpc
resouce "aws_vpc" "main_vpc" {
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
        "Name"                                                 = "${var.environment}-private-${local.zone1}"
        "Environment" = "${var.environment}"
        "kubernetes.io/role/internal-elb"                      = "1"
        "kubernetes.io/cluster/${var.env}-${var.project_name}" = "${var.project_name}"



    }
}