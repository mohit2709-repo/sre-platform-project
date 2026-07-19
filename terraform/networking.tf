############ VPC for AWS ############
resource "aws_vpc" "sre_vpc" {
    cidr_block           = "10.0.0.0/16"
    enable_dns_support   = true
    enable_dns_hostnames = true
    tags = {
        Name = "sre-project-vpc"
    }
}


############ Internet Gateway for VPC ############

resource "aws_internet_gateway" "sre_igw" {
    vpc_id = aws_vpc.sre_vpc.id
    tags = {
        Name = "sre-project-igw"
    }
}

############ Public Subnet 1 for VPC ############

resource "aws_subnet" "sre_public_subnet_1" {
    vpc_id                  = aws_vpc.sre_vpc.id
    cidr_block              = "10.0.1.0/24"
    availability_zone       = "${var.aws_region}a"
    map_public_ip_on_launch = true
    tags = {
        Name = "sre-project-public-subnet-1"
    }
}

############# Public Subnet 2 for VPC ############

resource "aws_subnet" "sre_public_subnet_2" {
    vpc_id                  = aws_vpc.sre_vpc.id
    cidr_block              = "10.0.2.0/24"
    availability_zone       = "${var.aws_region}b"
    map_public_ip_on_launch = true
    tags = {
        Name = "sre-project-public-subnet-2"
    }
}

############### Private Subnet 1 for VPC ###############

resource "aws_subnet" "sre_private_subnet_1" {
    vpc_id                  = aws_vpc.sre_vpc.id
    cidr_block              = "10.0.11.0/24"
    availability_zone       = "${var.aws_region}a"
    map_public_ip_on_launch = false
    tags = {
        Name = "sre-project-private-subnet-1"
    }
}

############### Private Subnet 2 for VPC ###############

resource "aws_subnet" "sre_private_subnet_2" {
    vpc_id                  = aws_vpc.sre_vpc.id
    cidr_block              = "10.0.12.0/24"
    availability_zone       = "${var.aws_region}b"
    map_public_ip_on_launch = false
    tags = {
        Name = "sre-project-private-subnet-2"
    }
}

############## Elastic IP for NAT Gateway ##############

resource "aws_eip" "sre_nat_eip" {
    domain = "vpc"
    tags = {
        Name = "sre-project-nat-eip"
    }
}

############# NAT Gateway for Private Subnets ##############

resource "aws_nat_gateway" "sre_nat_gw" {
    allocation_id = aws_eip.sre_nat_eip.id
    subnet_id     = aws_subnet.sre_public_subnet_1.id
    depends_on    = [aws_internet_gateway.sre_igw]
    tags = {
        Name = "sre-project-nat-gateway"
    }
}

############# Route Table for Public Subnets ############

resource "aws_route_table" "sre_public_rt" {
    vpc_id = aws_vpc.sre_vpc.id
    route {
        cidr_block = "0.0.0.0/0"
        gateway_id = aws_internet_gateway.sre_igw.id
    }
    tags = {
        Name = "sre-project-public-route-table"
    }
}

############ Route Table for Private Subnets ############

resource "aws_route_table" "sre_private_rt" {
    vpc_id = aws_vpc.sre_vpc.id
    route {
        cidr_block     = "0.0.0.0/0"
        nat_gateway_id = aws_nat_gateway.sre_nat_gw.id
    }
    tags = {
        Name = "sre-project-private-route-table"
    }
}


############ Associate Public Subnet 1 with Public Route Table ###########

resource "aws_route_table_association" "sre_public_subnet_1_assoc" {
    subnet_id      = aws_subnet.sre_public_subnet_1.id
    route_table_id = aws_route_table.sre_public_rt.id
}

############ Associate Public Subnet 2 with Public Route Table ###########

resource "aws_route_table_association" "sre_public_subnet_2_assoc" {
    subnet_id      = aws_subnet.sre_public_subnet_2.id
    route_table_id = aws_route_table.sre_public_rt.id
}

############ Associate Private Subnet 1 with Private Route Table ###########

resource "aws_route_table_association" "sre_private_subnet_1_assoc" {
    subnet_id      = aws_subnet.sre_private_subnet_1.id
    route_table_id = aws_route_table.sre_private_rt.id
}

############ Associate Private Subnet 2 with Private Route Table ###########

resource "aws_route_table_association" "sre_private_subnet_2_assoc" {
    subnet_id      = aws_subnet.sre_private_subnet_2.id
    route_table_id = aws_route_table.sre_private_rt.id
}
