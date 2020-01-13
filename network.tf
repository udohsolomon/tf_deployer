resource "aws_vpc" "vpc" {
    cidr_block                = "10.0.0.0/16"   # Defines overall VPC address space
    enable_dns_hostnames      = true            # Enable DNS hostnames for this VPC
    enable_dns_support        = true            # Enable DNS resolving support for this VPC
    tags = {
        Name                  = "VPC-${var.environment}" # Tag VPC with name
    }
}

resource "aws_subnet" "public-web-az-a" {
    availability_zone         = "us-east-1a"    # Define AZ for subnet
    cidr_block                = "10.0.1.0/24"   # Define CIDR-block for subnet
    map_public_ip_on_launch   = true            # Map public IP to deployed instances in this VPC
    vpc_id                    = aws_vpc.vpc.id  # Link Subnet to VPC
    tags = {
        Name                  = "Subnet-US-East-1a-Web" # Tag subnet with name
    }
}

resource "aws_subnet" "public-web-az-b" {
    availability_zone           = "us-east-1b"
    cidr_block                  = "10.0.2.0/24"
    map_public_ip_on_launch     = true
    vpc_id                      = aws_vpc.vpc.id
    tags = {
        Name                    = "Subnet-US-East-1b-Web"
    }
}

resource "aws_subnet" "private-db-az-a" {
    availability_zone           = "us-east-1a"
    cidr_block                  = "10.0.3.0/24"
    map_public_ip_on_launch     = false
    vpc_id                      = aws_vpc.vpc.id
    tags = {
        Name                    = "Subnet-US-East-1a-DB"
  }
}

resource "aws_subnet" "private-db-az-b" {
    availability_zone           = "us-east-1b"
    cidr_block                  = "10.0.4.0/24"
    map_public_ip_on_launch     = false
    vpc_id                      = aws_vpc.vpc.id
      tags = {
          Name                  = "Subnet-US-East-1b-DB"
    }
}

resource "aws_internet_gateway" "inetgw" {
    vpc_id                      = aws_vpc.vpc.id
    tags = {
        Name                    = "IGW-VPC-${var.environment}-Default"
    }
}

resource "aws_route_table" "us-default" {
    vpc_id                      = aws_vpc.vpc.id
    route {
        cidr_block              = "0.0.0.0/0"                       # Defines default route 
        gateway_id              = aws_internet_gateway.inetgw.id    # via IGW
    }
    tags = {
        Name                    = "Route-Table-US-Default"
    }
}

resource "aws_route_table_association" "us-east-1a-public" {
    subnet_id                   = aws_subnet.public-web-az-a.id
    route_table_id              = aws_route_table.us-default.id
}

resource "aws_route_table_association" "us-east-1b-public" {
    subnet_id                   = aws_subnet.public-web-az-b.id
    route_table_id              = aws_route_table.us-default.id
}


resource "aws_route_table_association" "us-east-1a-private" {
    subnet_id                   = aws_subnet.private-db-az-a.id
    route_table_id              = aws_route_table.us-default.id
}

resource "aws_route_table_association" "us-east-1b-private" {
    subnet_id                   = aws_subnet.private-db-az-b.id
    route_table_id              = aws_route_table.us-default.id
}