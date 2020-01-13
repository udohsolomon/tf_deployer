variable "region" {
    default         = "us-east-1"
}

variable "aws_ubuntu_awis" {
    default         = {
        "us-east-1" = "ami-cfe4b2b0"
    }
}

variable "environment" {
    type            = string
}

variable "application"  {
    type            = string
}

variable "key_name" {
    type            = string
    default         = "ec2key"
}

variable "mgmt_ips" {
    default         = ["0.0.0.0/0"]
}