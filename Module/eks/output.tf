output "cluster_name" {
    value = aws_eks_cluster.eks_cluster.name
}
output "cluster_endpoint" {
  value = aws_eks_cluster.eks_cluster.endpoint
}
output "update_kubeconfig"{
    value = "aws eks update-kubeconfig --region ${data.aws_region.current.region} --name ${aws_eks_cluster.eks_cluster.name}"
}
