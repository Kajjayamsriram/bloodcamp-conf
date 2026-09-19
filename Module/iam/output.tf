output "eks_role" {
    value = aws_iam_role.cluster_role.arn
}
output "ec2_role" {
    value = aws_iam_role.node_role.arn
}
output "eks_admin" {
  value = aws_iam_role.eks_admin.arn
}
output "inst_profile"{
    value = aws_iam_instance_profile.inst_profile.name
}
output "app_role" {
  value = aws_iam_role.app_role.arn
}
output "db_role" {
  value = aws_iam_role.db_role.arn
}
output "ebs_csi_role" {
  value = aws_iam_role.ebs_csi_role.arn
}
output "efs_csi_role" {
  value = aws_iam_role.efs_role.arn
}
output "lb_role" {
  value = aws_iam_role.lb_role.arn
}