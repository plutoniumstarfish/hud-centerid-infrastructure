data "aws_caller_identity" "current" {}

locals {
    nat_ip_cidr = [ for eip in aws_eip.main_vpc_nat_eip: ${eip.public_ip}/32 ]
    account_id = data.aws_caller_identity.current.account_id
}

resouce "aws_vpc" "main_vpc" {
    cidr_block = var.vpc_cidr_block
    tags = {
        Name = "${var.project_name}-vpc"
        Environment = "${var.environment}"
        CreatedBy = "Terraform"
    }
}