
module "eks" {
  source  = "terraform-aws-modules/eks/aws"
  version = "19.15"

  cluster_name = "devsecops-chaos-cluster"
  cluster_version = "1.28"

  eks_managed_node_groups = {
    default = {
      instance_types = ["t3.medium"]
      min_size = 1
      max_size = 2
      desired_size = 1
    }
  }
}
