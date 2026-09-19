variable "security_groups" {
    type =map(object({
        ingress_rules = list(object({
            port =number
            protocol = string
            cidr =string
        }))
        egress_rules = list(object({
            port =number
            protocol = string
            cidr =string
        }))
    }))
}

variable "vpc_id" {
  type =string
}