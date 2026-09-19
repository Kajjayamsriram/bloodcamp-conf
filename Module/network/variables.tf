variable "vpc_name" {
    type = string
}
variable "vpc_cidr" {
    type = string
}
variable "dns" {
    type = bool
}
variable "subnets" {
    type = map(object({
        cidr = string
        az =string
        ip = bool
    }))
}
variable "igw_name" {
    type = string
}
variable "domain" {
    type = string
}
variable "eip_name" {
    type = string
}
variable "nat_name" {
    type = string
}
variable "av_mode" {
    type = string
}
variable "con_type" {
    type = string
}
variable "pub_rt_name" {
    type = string
}
variable "pvt_rt_name" {
    type = string
}
