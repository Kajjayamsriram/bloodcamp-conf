module "network" {
  source = "./Module/network"
  vpc_name = "alpha_dev"
  
  vpc_cidr = "10.0.0.0/22"
  dns = true
  subnets = {
    public1 = {
        az = "us-east-1a"
        ip = true
        cidr = "10.0.0.0/26"
    }
    private1 = {
        az = "us-east-1a"
        ip = false
        cidr = "10.0.1.0/26"
    }
    private2 = {
        az = "us-east-1b"
        ip = false
        cidr = "10.0.1.64/26"
    }
  }
  igw_name = "alpha_dev"
  domain = "vpc"
  eip_name = "alpha_dev"
  nat_name = "alpha_dev"
  av_mode = "regional"
  con_type = "public"
  pub_rt_name = "alpha_pub_dev"
  pvt_rt_name = "alpha_pvt_dev"
}

module "iam" {
    source = "./Module/iam"
    eks_policy = "AmazonEKSClusterPolicy"
    ec2_policy = [
        "AmazonEKSWorkerNodePolicy",
        "AmazonEC2ContainerRegistryPullOnly",
        "AmazonEKS_CNI_Policy"
    ]
    # cluster_identity = module.eks.aws_eks_cluster.eks_cluster.identity[0].oidc[0].issuer
    ebs_policy = "AmazonEBSCSIDriverPolicy"
    vpc_cni_policy = "AmazonEKS_CNI_Policy"
    lb_policy = file("${path.module}/iam_policy.json")
    efs_cni_policy = "AmazonEFSCSIDriverPolicy"
}
module "eks" {
  source = "./Module/eks"
  cluster_name = "alpha_dev_cluster"
  cluster_version = 1.34

  node_role = module.iam.ec2_role
  cluster_role = module.iam.eks_role
  sg = module.sg.sg["eks"]
  subnets = [ module.network.subnets["private1"], module.network.subnets["private2"] ]

  #launch_template = module.lt.launch_template
  #launch_template_version = module.lt.launch_template_version

  itype = "c7i-flex.large"
  node_group_name = "alpha_dev_nodegroup"
  node_max_size = 4
  node_min_size = 3
  node_max_unavail = 2
  node_desired = 2
  environment = "dev"

  eks_cluster_access = "AmazonEKSClusterAdminPolicy"
  eksadmin_principal_arn = module.iam.eks_admin
  db_service_account_name = "db-sa"
  db_role = module.iam.db_role
  namespace = "bank-dev"
  app_service_account_name = "app-sa"
  app_role = module.iam.app_role
  ebs_csi_role = module.iam.ebs_csi_role
  efs_csi_role = module.iam.efs_csi_role
  lb_role = module.iam.lb_role


  depends_on = [ module.network, module.sg ]
}
module "sg" {
    source  = "./Module/sg"
    vpc_id = module.network.vpc_id
    security_groups = {
      eks = {
        ingress_rules = [
            {
                port = 0
                protocol = "-1"
                cidr = "0.0.0.0/0"
            }
        ]
        egress_rules = [
            {
                port = 0
                protocol = "-1"
                cidr = "0.0.0.0/0"
            }
        ]
      },
      ec2 = {
        ingress_rules = [
            {
                port = 80
                protocol= "tcp"
                cidr = "0.0.0.0/0"
            },
            {
                port = 22
                protocol = "tcp"
                cidr = "0.0.0.0/0"
            },
            {
                port = 8080
                protocol = "tcp"
                cidr = "0.0.0.0/0"
            },
            {
                port = 9000
                protocol = "tcp"
                cidr = "0.0.0.0/0"
            }
        ]
        egress_rules = [
            {
                port= 0
                protocol = "-1"
                cidr = "0.0.0.0/0"
            }
        ]
      }
    }
    depends_on = [ module.network ]
}

module "ec2" {
    source = "./Module/ec2"
    instances = {
      Jenkins ={
        itype = "m7i-flex.large"
        ami = "ami-0e34b50e714a297f1"
        subnet_id = module.network.subnets["public1"]
        sg = module.sg.sg["ec2"]
        vol_size = 10
        inst_profile = module.iam.inst_profile
      }
    }

    tags = {
        Env = "dev"
        Name = "Jenkins_server"
    }

    udata = templatefile("${path.module}/eks_script.sh",{
    region = data.aws_region.current.region
    cluster_name = module.eks.cluster_name
    })
    depends_on = [ module.iam, module.network, module.sg ]
}
module "ecr_repo" {
  source = "./Module/ecr"
  repos = {
    blood-app ={
        mutability = "MUTABLE"
        encrypt = "AES256"
    },
    blood-db ={
        mutability = "MUTABLE"
        encrypt = "AES256"
    }
  }
}