variable "eks_policy" {
    type = string
}
variable "ec2_policy" {
    type = set(string)
}
# variable "cluster_identity" {
#     type = string
# }
variable "ebs_policy" {
    type = string
}
variable "efs_cni_policy" {
  type = string
}
variable "vpc_cni_policy" {
  type = string
}
variable "lb_policy" {
  type = string
}