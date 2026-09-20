resource "aws_eks_cluster" "eks_cluster" {
    name = var.cluster_name
    version  = var.cluster_version

    role_arn = var.cluster_role
    vpc_config {
        subnet_ids = var.subnets
        #endpoint_private_access = true
        endpoint_public_access  = true
        security_group_ids = [
            var.sg
        ]
    }
    access_config {
        authentication_mode = "API_AND_CONFIG_MAP"
        bootstrap_cluster_creator_admin_permissions = true
    }

    enabled_cluster_log_types = [
    "api",
    "controllerManager",
    "scheduler"
    ]

    #add-on to manage by you rather eks - vpc_cni,coredns,kube_proxy
}

resource "aws_eks_node_group" "node_group" {
    cluster_name = aws_eks_cluster.eks_cluster.name
    node_group_name = var.node_group_name
    node_role_arn = var.node_role
    subnet_ids = var.subnets
    # capacity_type = "ON_DEMAND"
    scaling_config {
        max_size = var.node_max_size
        min_size = var.node_min_size
        desired_size = var.node_desired
    }
    #eks cluster info with CA needed in user_data and custom_aws_ami, so ignoring launch_template to reduce complexity used itype.
    instance_types = [ var.itype ]

    update_config {
        max_unavailable = var.node_max_unavail
    }
    labels = {
        Environment = var.environment
    }
    lifecycle {
        ignore_changes = [ scaling_config[0].desired_size ]
    }
}

#gets the region name from provider block
data "aws_region" "current" {}

resource "aws_eks_access_entry" "eks_entry" {
    cluster_name = aws_eks_cluster.eks_cluster.name
    principal_arn = var.eksadmin_principal_arn # aws_iam_role.eks_admin.arn
    type = "STANDARD" #iamuser/role -> standard
}
resource "aws_eks_access_policy_association" "admin" {
  cluster_name = aws_eks_cluster.eks_cluster.name
  policy_arn = "arn:aws:eks::aws:cluster-access-policy/${var.eks_cluster_access}"
  principal_arn = var.eksadmin_principal_arn # aws_iam_role.eks_admin.arn

  access_scope {
    type = "cluster"
  }
}
#AmazonEKSClusterAdminPolicy

resource "aws_eks_pod_identity_association" "ebs_csi" {
  cluster_name    = aws_eks_cluster.eks_cluster.name
  namespace       = "kube-system"
  service_account = "ebs-csi-controller-sa"
  role_arn        = var.ebs_csi_role
}

resource "aws_eks_pod_identity_association" "efs_csi" {
  cluster_name    = aws_eks_cluster.eks_cluster.name
  namespace       = "kube-system"
  service_account = "efs-csi-controller-sa"
  role_arn        = var.efs_csi_role
}

resource "aws_eks_pod_identity_association" "lb_csi" {
  cluster_name    = aws_eks_cluster.eks_cluster.name
  namespace       = "kube-system"
  service_account = "aws-load-balancer-controller"
  role_arn        = var.lb_role
}

resource "aws_eks_pod_identity_association" "app_pod" {
    cluster_name = aws_eks_cluster.eks_cluster.name
    namespace = var.namespace
    service_account = var.app_service_account_name
    role_arn = var.app_role #aws_iam_role.app_role.arn
}
resource "aws_eks_pod_identity_association" "db_pod" {
    cluster_name = aws_eks_cluster.eks_cluster.name
    namespace = var.namespace
    service_account = var.db_service_account_name
    role_arn = var.db_role #aws_iam_role.db_role.arn
}