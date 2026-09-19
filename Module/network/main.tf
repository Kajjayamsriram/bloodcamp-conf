resource "aws_vpc" "vpc1" {
    tags = {
        Name = var.vpc_name
    }
    cidr_block = var.vpc_cidr
    enable_dns_hostnames = var.dns
}

resource "aws_subnet" "subnets" {
    vpc_id = aws_vpc.vpc1.id
    for_each = var.subnets
    tags = {
        Name = each.key
    }
    cidr_block = each.value.cidr
    availability_zone = each.value.az
    map_public_ip_on_launch = each.value.ip
    depends_on = [ aws_vpc.vpc1 ]
}

resource "aws_internet_gateway" "igw1" {
    vpc_id = aws_vpc.vpc1.id
    tags = {
        Name = var.igw_name
    }
    depends_on = [ aws_subnet.subnets ]
}

resource "aws_eip" "eip1" {
    domain = var.domain
    tags = {
        Name = var.eip_name
    }
    depends_on = [ aws_subnet.subnets ]
}
resource "aws_nat_gateway" "nat1" {
    vpc_id = aws_vpc.vpc1.id
    tags = {
        Name = var.nat_name
    }
    allocation_id = aws_eip.eip1.id
    availability_mode = var.av_mode
    connectivity_type = var.con_type
    depends_on = [ aws_internet_gateway.igw1 ]
}

resource "aws_route_table" "pub_rt" {
    tags = {
        Name = var.pub_rt_name
    }
    vpc_id = aws_vpc.vpc1.id
    depends_on = [ aws_vpc.vpc1 ]
}
resource "aws_route_table" "pvt_rt" {
    tags = {
        Name = var.pvt_rt_name
    }
    vpc_id = aws_vpc.vpc1.id
    depends_on = [ aws_vpc.vpc1 ]
}

resource "aws_route" "pub_rt" {
    route_table_id = aws_route_table.pub_rt.id
    gateway_id = aws_internet_gateway.igw1.id
    destination_cidr_block = "0.0.0.0/0"
    depends_on = [ aws_internet_gateway.igw1 ]
}
resource "aws_route" "pvt_rt" {
    route_table_id = aws_route_table.pvt_rt.id
    nat_gateway_id = aws_nat_gateway.nat1.id
    destination_cidr_block = "0.0.0.0/0"
    depends_on = [ aws_nat_gateway.nat1 ]
}

resource "aws_route_table_association" "rt_association" {
    for_each = var.subnets
    route_table_id = each.value.ip ? aws_route_table.pub_rt.id : aws_route_table.pvt_rt.id
    subnet_id = aws_subnet.subnets[each.key].id
    depends_on = [ aws_route.pub_rt, aws_route.pvt_rt ]
}