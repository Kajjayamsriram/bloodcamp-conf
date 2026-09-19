
#add-ons##
resource "aws_eks_addon" "ebs_csi" {
  cluster_name = aws_eks_cluster.eks_cluster.name
  addon_name = "aws-ebs-csi-driver"
  service_account_role_arn = var.ebs_csi_role #aws_iam_role.ebs_csi_role.arn
}

resource "aws_eks_addon" "vpc_cni" {
    cluster_name = aws_eks_cluster.eks_cluster.name
    addon_name = "vpc-cni"
}

resource "aws_eks_addon" "coredns" {
  cluster_name = aws_eks_cluster.eks_cluster.name
  addon_name = "coredns"
}

resource "aws_eks_addon" "kube_proxy" {
  cluster_name = aws_eks_cluster.eks_cluster.name
  addon_name = "kube-proxy"
}

resource "aws_eks_addon" "efs_driver" {
  cluster_name = aws_eks_cluster.eks_cluster.name
  addon_name = "aws-efs-csi-driver"
  service_account_role_arn = var.efs_csi_role #aws_iam_role.efs_csi_role.arn
}

resource "helm_release" "lb_driver" {
    name       = "aws_lb_controller"
    repository = "https://aws.github.io/eks-charts"
    chart      = "aws-load-balancer-controller"
    namespace  = "kube-system"

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
        }
    ]
}