##############VPC Outputs##############

output "vpc_id" {
    description = "The ID of the VPC"
    value = aws_vpc.sre_vpc.id
}

##############Public Subnet Outputs##############
output "public_subnet_ids" {
    description = "The IDs of the public subnets"
    value = [aws_subnet.sre_public_subnet_1.id, aws_subnet.sre_public_subnet_2.id]
}

##############Private Subnet Outputs##############
output "private_subnet_ids" {
    description = "The IDs of the private subnets"
    value = [aws_subnet.sre_private_subnet_1.id, aws_subnet.sre_private_subnet_2.id]
}

###############Internet Gateway Outputs##############
output "internet_gateway_id" {
    description = "The ID of the Internet Gateway"
    value = aws_internet_gateway.sre_igw.id
}

###############NAT Gateway Outputs##############
output "nat_gateway_id" {
    description = "The ID of the NAT Gateway"
    value = aws_nat_gateway.sre_nat_gw.id
}   

################EKS Cluster Outputs##############
output "eks_cluster_name" {
    description = "The name of the EKS cluster"
    value = aws_eks_cluster.sre_eks_cluster.name
}
output "eks_cluster_endpoint" {
    description = "The endpoint of the EKS cluster"
    value = aws_eks_cluster.sre_eks_cluster.endpoint
}
output "eks_cluster_arn" {
    description = "The ARN of the EKS cluster"
    value = aws_eks_cluster.sre_eks_cluster.arn
}

output "eks_cluster_version" {
    description = "The version of the EKS cluster"
    value = aws_eks_cluster.sre_eks_cluster.version
}

#################EKS Node Group Outputs##############
output "eks_node_group_name" {
    description = "The name of the EKS node group"
    value = aws_eks_node_group.sre_eks_node_group.node_group_name
}
output "eks_node_group_arn" {
    description = "The ARN of the EKS node group"
    value = aws_eks_node_group.sre_eks_node_group.arn
}
output "eks_node_group_status" {
    description = "The status of the EKS node group"
    value = aws_eks_node_group.sre_eks_node_group.status
}  

#################IAM Role Outputs##############
output "eks_cluster_role_arn" {
    description = "The ARN of the EKS cluster IAM role"
    value = aws_iam_role.eks_cluster_role.arn
}
output "eks_node_group_role_arn" {
    description = "The ARN of the EKS node group IAM role"
    value = aws_iam_role.eks_node_group_role.arn
}

output "ebs_csi_driver_role_arn" {
    description = "The ARN of the EBS CSI Driver IAM role"
    value = aws_iam_role.ebs_csi_driver_role.arn
}

output "ebs_csi_driver_policy_attachment_id" {
    description = "The ID of the EBS CSI Driver IAM policy attachment"
    value = aws_iam_role_policy_attachment.ebs_csi_driver_policy_attachment.id
}

output "ebs_csi_driver_addon_name" {
    description = "The name of the EBS CSI Driver addon"
    value = aws_eks_addon.ebs_csi_driver.addon_name
}