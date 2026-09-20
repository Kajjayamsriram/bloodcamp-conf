variable "cluster_name" {
    type = string
}
variable "cluster_version" {
    type = number
}
variable "node_group_name" {
    type = string
}
variable "node_max_size"{
    type = number
}
variable "node_min_size"{
    type = number
}
variable "node_desired"{
    type = number
}
variable "node_max_unavail"{
    type = number
}
variable "environment"{
    type = string
}
variable "sg"{
    type = string
}
variable "cluster_role" {
    type = string
}
variable "node_role" {
  type = string
}
variable "subnets" {
  type = list(string)
}
# variable "launch_template"{
#     type = string
# }
# variable "launch_template_version" {
#     type = string
# }
variable "itype" {
  type = string
}
variable "eksadmin_principal_arn" {
  type = string
}
variable "eks_cluster_access" {
  type = string
}
variable "ebs_csi_role" {
  type = string
}
variable "efs_csi_role" {
  type = string
}
variable "lb_role" {
  type = string
}
variable "namespace" {
  type = string
}
variable "app_service_account_name" {
  type = string
}
variable "db_service_account_name" {
  type = string
}
variable "db_role" {
  type = string
}
variable "app_role" {
  type = string
}
variable "vpc_id" {
  type = string
}