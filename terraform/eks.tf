###############Create EKS Cluster####################

resource "aws_eks_cluster" "sre_eks_cluster" {
  name     = "sre-eks-cluster"
  role_arn = aws_iam_role.eks_cluster_role.arn
  version = "1.31"

  vpc_config {
    subnet_ids = [
      aws_subnet.sre_public_subnet_1.id,
      aws_subnet.sre_public_subnet_2.id,
      aws_subnet.sre_private_subnet_1.id,
      aws_subnet.sre_private_subnet_2.id,
    ]
  }

  depends_on = [
    aws_iam_role_policy_attachment.eks_cluster_policy,
  ]
}

################Create EKS Node Group####################

resource "aws_eks_node_group" "sre_eks_node_group" {
  cluster_name    = aws_eks_cluster.sre_eks_cluster.name
  node_group_name = "sre-eks-node-group"
  node_role_arn   = aws_iam_role.eks_node_group_role.arn
  subnet_ids      = [aws_subnet.sre_private_subnet_1.id, aws_subnet.sre_private_subnet_2.id]

  instance_types = ["t3.medium"]
  capacity_type = "ON_DEMAND"
  ami_type = "AL2023_x86_64_STANDARD"
  scaling_config {
    desired_size = 1
    max_size     = 2
    min_size     = 1
  }

  update_config {
    max_unavailable = 1
  } 


  depends_on = [
    aws_iam_role_policy_attachment.eks_worker_node_policy,
    aws_iam_role_policy_attachment.eks_cni_policy,
    aws_iam_role_policy_attachment.eks_registry_policy,
  ]
}