resource "aws_iam_role" "cluster_role" {
    name = "eks_role"
    assume_role_policy = jsonencode({
        Version = "2012-10-17"
        Statement = [
            {
                "Effect": "Allow",
                "Principal": {
                    "Service" : [
                        "eks.amazonaws.com"
                    ]
                },  
                "Action": "sts:AssumeRole"
            }
        ]
    })
}
resource "aws_iam_role_policy_attachment" "eks_policy" {
    role = aws_iam_role.cluster_role.name
    policy_arn = "arn:aws:iam::aws:policy/${var.eks_policy}"
}

#AmazonEKSClusterPolicy

resource "aws_iam_role" "node_role" {
    name = "node_role"
    assume_role_policy = jsonencode({
        "Version" : "2012-10-17"
        "Statement" : [
            {
                "Effect" : "Allow"
                "Principal" : {
                    "Service" : [
                        "ec2.amazonaws.com"
                    ]
                },
                "Action" : "sts:AssumeRole"
            }
        ]
    })
}
resource "aws_iam_role_policy_attachment" "ec2_policy" {
    for_each = var.ec2_policy
    role = aws_iam_role.node_role.name
    policy_arn = "arn:aws:iam::aws:policy/${each.value}"
}

#AmazonEKSWorkerNodePolicy,AmazonEC2ContainerRegistryPullOnly,AmazonEKS_CNI_Policy

#ec2 Iam role access for the EKS cluster
resource "aws_iam_role" "eks_admin" {
    name = "ec2_access_cluster"
    assume_role_policy = jsonencode({
        "Version" : "2012-10-17"
        "Statement" : [
        {
            "Effect" : "Allow"
            "Principal" : {
                "Service" : [
                    "ec2.amazonaws.com"
                ]
            },
            "Action" : "sts:AssumeRole"
        }
        ]
    })
}
resource "aws_iam_role_policy" "eks_describe" {
    role = aws_iam_role.eks_admin.name
    policy = jsonencode({
        "Version" = "2012-10-17",
        "Statement" = [
            {
                "Effect" = "Allow",
                "Action" = [
                    "eks:DescribeCluster",
                    "ecr:GetAuthorizationToken",
                    "ecr:BatchCheckLayerAvailability",
                    "ecr:InitiateLayerUpload",
                    "ecr:UploadLayerPart",
                    "ecr:CompleteLayerUpload",
                    "ecr:PutImage"
                ]
                "Resource" = "*"
            }
        ]
    })
}

#To connect from ec2 attach this role
resource "aws_iam_instance_profile" "inst_profile" {
  role = aws_iam_role.eks_admin.name
  name = "inst_profile"
}

##Pod to access to external AWS Services. Via ServiceAccount
#The AWS Pod Identity feature is the modern, simplified replacement for the older IAM Roles for Service Accounts (IRSA) method
# data "tls_certificate" "eks" {
#   url = var.cluster_identity #aws_eks_cluster.eks_cluster.identity[0].oidc[0].issuer
# }

# resource "aws_iam_openid_connect_provider" "eks" {
#   url = var.cluster_identity #aws_eks_cluster.eks_cluster.identity[0].oidc[0].issuer

#   client_id_list = [
#     "sts.amazonaws.com"
#   ]

#   thumbprint_list = [
#     data.tls_certificate.eks.certificates[0].sha1_fingerprint
#   ]
# }

#Role to csi-drive for it's SA
resource "aws_iam_role" "ebs_csi_role" {
    name = "ebs-csi-role"
    assume_role_policy = jsonencode({
    Version = "2012-10-17"
        Statement = [{
        Effect = "Allow"
        Principal = {
            Service = "pods.eks.amazonaws.com"
        }
        Action = [
            "sts:AssumeRole",
            "sts:TagSession"
        ]
        }]
    })
}

resource "aws_iam_role_policy_attachment" "ebs_csi_drive" {
    role = aws_iam_role.ebs_csi_role.name
    policy_arn = "arn:aws:iam::aws:policy/service-role/${var.ebs_policy}" #AmazonEBSCSIDriverPolicy
}

resource "aws_iam_role_policy_attachment" "vpc_cni" {
    role = aws_iam_role.node_role.name
    policy_arn = "arn:aws:iam::aws:policy/${var.vpc_cni_policy}" #AmazonEKS_CNI_Policy
}
#Using the above node_role

resource "aws_iam_role" "efs_role" {
    name = "fs-csi-role"
    assume_role_policy = jsonencode({
        #old fashioned and complex compared to pod_identity_association
        # "Version" : "2012-10-17",
        # "Statement" : [
        #     {
        #         "Effect" : "Allow",
        #         "Principal" : {
        #             "Federated" : aws_iam_openid_connect_provider.eks.arn
        #         },
        #         "Action" : "sts:AssumeRoleWithWebIdentity",
        #         "Condition" : {
        #             StringEquals : {
        #                 "${replace(
        #                 var.cluster_identity,
        #                 "https://",
        #                 ""
        #                 )}:aud" = "sts.amazonaws.com"
        #                 "${replace(
        #                 var.cluster_identity,
        #                 "https://",
        #                 ""
        #                 )}:sub" = "system:serviceaccount:kube-system:efs-csi-controller-sa"
        #             }
        #         }
        #     }
        # ]
        Version = "2012-10-17"
        Statement = [{
        Effect = "Allow"
        Principal = {
            Service = "pods.eks.amazonaws.com"
        }
        Action = [
            "sts:AssumeRole",
            "sts:TagSession"
        ]
        }]
    })
}

resource "aws_iam_role_policy_attachment" "efs_role" {
    role = aws_iam_role.efs_role.name
    policy_arn = "arn:aws:iam::aws:policy/service-role/${var.efs_cni_policy}" #AmazonEFSCSIDriverPolicy
}

resource "aws_iam_role" "lb_role" {
    name = "lb-csi-role"
    assume_role_policy = jsonencode({
        Version = "2012-10-17"
        Statement = [{
            Effect = "Allow"
            Principal = {
                Service = "pods.eks.amazonaws.com"
            }
            Action = [
                "sts:AssumeRole",
                "sts:TagSession"
            ]
        }]
    })
}
resource "aws_iam_role_policy" "lb_role" {
    role = aws_iam_role.lb_role.name
    policy = var.lb_policy #file("${path.module}/iam_policy.json")
}

#pod gets s3 access
resource "aws_iam_role" "app_role" {
    name = "pod-s3-role"
    assume_role_policy = jsonencode({
        "Version" : "2012-10-17"
        "Statement" : [
            {
                "Effect" : "Allow"
                "Principal" : {
                    "Service" : [
                        "pods.eks.amazonaws.com"
                    ]
                },
                "Action" : [
                    "sts:AssumeRole", "sts:TagSession"
                ]
            }
        ]
    })
}

resource "aws_iam_role_policy_attachment" "app_s3" {
  role       = aws_iam_role.app_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonS3ReadOnlyAccess"
}

#pod to grant db access
resource "aws_iam_role" "db_role" {
    name = "pod-db-role"
    assume_role_policy = jsonencode({
        "Version" : "2012-10-17"
        "Statement" : [
            {
                "Effect" : "Allow"
                "Principal" : {
                    "Service" : [
                        "pods.eks.amazonaws.com"
                    ]
                },
                "Action" : [
                    "sts:AssumeRole", "sts:TagSession"
                ]
            }
        ]
    })
}

resource "aws_iam_role_policy" "db_role" {
    role = aws_iam_role.db_role.name
    policy = jsonencode({
    "Version" : "2012-10-17"
        "Statement" : [
            {
                "Effect" : "Allow"
                "Action" : "rds-db:connect"
                "Resource" : "*"
            }
        ]
  })
}