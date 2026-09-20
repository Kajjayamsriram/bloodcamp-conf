
#add-ons##
#add-on versions that support eks clsuter =>1.34 Version
resource "aws_eks_addon" "ebs_csi" {
  cluster_name = aws_eks_cluster.eks_cluster.name
  addon_name = "aws-ebs-csi-driver"
  addon_version = "v1.66.0-eksbuild.1" #var.ebs_csi_version

#   service_account_role_arn = var.ebs_csi_role #aws_iam_role.ebs_csi_role.arn

  resolve_conflicts_on_create = "OVERWRITE"
  resolve_conflicts_on_update = "OVERWRITE"
  depends_on = [
    aws_eks_node_group.node_group
  ]
}

resource "aws_eks_addon" "vpc_cni" {
    cluster_name = aws_eks_cluster.eks_cluster.name
    addon_name = "vpc-cni"
    addon_version = "v1.23.1-eksbuild.1" #var.vpc_cni_version

    resolve_conflicts_on_create = "OVERWRITE"
    resolve_conflicts_on_update = "OVERWRITE"
}

resource "aws_eks_addon" "coredns" {
  cluster_name = aws_eks_cluster.eks_cluster.name
  addon_name = "coredns"
  addon_version = "v1.13.2-eksbuild.24" #var.coredns_version

  resolve_conflicts_on_create = "OVERWRITE"
  resolve_conflicts_on_update = "OVERWRITE"
  depends_on = [
    aws_eks_node_group.node_group
  ]
}

resource "aws_eks_addon" "kube_proxy" {
  cluster_name = aws_eks_cluster.eks_cluster.name
  addon_name = "kube-proxy"
  addon_version = "v1.34.6-eksbuild.25" #var.kube_proxy_version

  resolve_conflicts_on_create = "OVERWRITE"
  resolve_conflicts_on_update = "OVERWRITE"
}

resource "aws_eks_addon" "efs_driver" {
  cluster_name = aws_eks_cluster.eks_cluster.name
  addon_name = "aws-efs-csi-driver"
  addon_version = "v3.4.2-eksbuild.1" #var.efs_driver_version

#   service_account_role_arn = var.efs_csi_role #aws_iam_role.efs_csi_role.arn
  resolve_conflicts_on_create = "OVERWRITE"
  resolve_conflicts_on_update = "OVERWRITE"
  depends_on = [
    aws_eks_node_group.node_group
  ]
}

resource "helm_release" "lb_driver" {
    name       = "aws-lb-controller"
    repository = "https://aws.github.io/eks-charts"
    chart      = "aws-load-balancer-controller"
    namespace  = "kube-system"
    version = "1.14.0" #var.lb_driver_version

    set = [
        {
        name  = "clusterName"
        value = aws_eks_cluster.eks_cluster.name
        },
        {
        name  = "serviceAccount.create"
        value = "true"
        },
        {
        name  = "serviceAccount.name"
        value = "aws-load-balancer-controller"
        },
        {
        name = "serviceAccount.annotations.eks\\.amazonaws\\.com/role-arn"
        value = var.lb_role #aws_iam_role.lb_role.arn
        },
        {
        name  = "vpcId"
        value = var.vpc_id #module.vpc.vpc_id
        }
    ]
}

resource "aws_eks_addon" "pod_identity_agent" {
  cluster_name = aws_eks_cluster.eks_cluster.name
  addon_name   = "eks-pod-identity-agent"
  addon_version = "v1.4.0-eksbuild.2"
  
  resolve_conflicts_on_create = "OVERWRITE"
  resolve_conflicts_on_update = "OVERWRITE"
}