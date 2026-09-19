output "subnets" {
    value = {
        for name, subnet in aws_subnet.subnets :
        name => subnet.id
    }
}
output "vpc_id" {
    value = aws_vpc.vpc1.id 
}