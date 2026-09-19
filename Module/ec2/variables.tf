variable "tags" {
  type = map(string)
}
variable "instances" {
  type = map(object({
    itype = string
    ami = string
    subnet_id = string
    sg = string
    vol_size = number
    inst_profile = optional(string)
  }))
}
variable "udata" {
    type =  string
}