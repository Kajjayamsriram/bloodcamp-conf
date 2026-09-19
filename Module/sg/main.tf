resource "aws_security_group" "sg" {
    vpc_id = var.vpc_id
    for_each = var.security_groups
    
    name = each.key
    description = "security group for cluster"
    dynamic "ingress" {
        for_each = each.value.ingress_rules
        content {
            from_port  = ingress.value.port
            to_port  = ingress.value.port
            protocol = ingress.value.protocol
            cidr_blocks = [ingress.value.cidr]
        }
    }
    dynamic "egress" {
        for_each = each.value.egress_rules
        content {
            from_port  = egress.value.port
            to_port  = egress.value.port
            protocol = egress.value.protocol
            cidr_blocks = [egress.value.cidr]
        }
    }
}