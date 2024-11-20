//1. create vpc

resource "aws_vpc" "custom_vpc" {
  cidr_block           = "10.0.0.0/16"
  enable_dns_hostnames = true
  enable_dns_support   = true
  tags = {
    Name = "yt-vpc"
  }
}

//2. create subnet

resource "aws_subnet" "public_subnet" {
  vpc_id            = aws_vpc.custom_vpc.id
  count             = length(var.vpc_availability_zones)
  cidr_block        = cidrsubnet(aws_vpc.custom_vpc.cidr_block, 8, count.index + 1)
  availability_zone = element(var.vpc_availability_zones, count.index)
  tags = {
    Name = "YT Private subnet ${count.index + 1}"
  }
}

/*
for example : 10.0.0.0/16
cidrsubnet (10.0.0.0/16,8,0+1) = 10.0.1.0/24
cidrsubnet (10.0.0.0/16,8,1+1) = 10.0.2.0/24
*/

# resource "aws_subnet" "private_subnet" {
#   vpc_id            = aws_vpc.custom_vpc.id
#   count             = length(var.vpc_availability_zones)
#   cidr_block        = cidrsubnet(aws_vpc.custom_vpc.cidr_block, 8, count.index + 3)
#   availability_zone = element(var.vpc_availability_zones, count.index)
#   tags = {
#     Name = "YT Private subnet ${count.index + 1}"
#   }
# } 

// 3. Internet gateway

resource "aws_internet_gateway" "igw_vpc" {
  vpc_id = aws_vpc.custom_vpc.id
  tags = {
    Name = "yt-ig"
  }
}

// 4. route table for public subnet 

resource "aws_route_table" "yt_route_table_public_subnet" {
  vpc_id = aws_vpc.custom_vpc.id
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.igw_vpc.id
  }
  tags = {
    Name = "Public subnet route table"
  }
}

//5. Association btw RT and IG

resource "aws_route_table_association" "public_subnet_association" {
  route_table_id = aws_route_table.yt_route_table_public_subnet.id
  count          = length(var.vpc_availability_zones)
  subnet_id      = element(aws_subnet.public_subnet[*].id, count.index)

}

# //6. Elastic IP
# resource "aws_eip" "eip" {
#   domain     = "vpc"
#   depends_on = [aws_internet_gateway.igw_vpc]
# }

# //7. NAT Gateway
# resource "aws_nat_gateway" "yt-nat-gateway" {
#   subnet_id     = element(aws_subnet.private_subnet[*].id, 0)
#   allocation_id = aws_eip.eip.id
#   depends_on    = [aws_internet_gateway.igw_vpc]
#   tags = {
#     Name = "YT-Nat Gateway"
#   }
# }

# //8. Route table for Private subnet
# resource "aws_route_table" "yt_route_table_private_subnet" {
#   vpc_id = aws_vpc.custom_vpc.id
#   route {
#     cidr_block = "0.0.0.0/0"
#     gateway_id = aws_nat_gateway.yt-nat-gateway.id
#   }
#   depends_on = [aws_nat_gateway.yt-nat-gateway]
#   tags = {
#     Name = " Private subnet Route Table"
#   }
# }

# //9. Route table association with private subnet
# resource "aws_route_table_association" "private_subnet_association" {
#   route_table_id = aws_route_table.yt_route_table_private_subnet.id
#   count          = length(var.vpc_availability_zones)
#   subnet_id      = element(aws_subnet.private_subnet[*].id, count.index)
# }