variable "aws_region" {
    type = string
    description = "Region to deploy resources"
    default = "us-east-1"
}

variable "vpc_cidr_block" {
    type = string
    description = "CIDR Block for the VPC"
}

variable "project_name" {
    type = string
    default = "hud-centerid"
}