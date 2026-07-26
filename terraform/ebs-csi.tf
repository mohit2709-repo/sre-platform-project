################################EKS cluster OIDC certificate###############################
data "tls_certificate" "eks_oidc" {
  url = aws_eks_cluster.sre_eks_cluster.identity[0].oidc[0].issuer
}

################################Create IAM OIDC Provider################################
resource "aws_iam_openid_connect_provider" "eks_oidc_provider" {
  url = aws_eks_cluster.sre_eks_cluster.identity[0].oidc[0].issuer
  client_id_list = ["sts.amazonaws.com"]
  thumbprint_list = [data.tls_certificate.eks_oidc.certificates[0].sha1_fingerprint]
}

################################Create IAM Policy for EBS CSI Driver################################
data "aws_iam_policy_document" "ebs_csi_driver_policy" {
  statement {
    actions = ["sts:AssumeRoleWithWebIdentity"]
    effect = "Allow"
    principals {
      type        = "Federated"
      identifiers = [aws_iam_openid_connect_provider.eks_oidc_provider.arn]
    }
    condition {
      test     = "StringEquals"
      variable = "${replace(aws_eks_cluster.sre_eks_cluster.identity[0].oidc[0].issuer, "https://", "")}:sub"
      values   = ["system:serviceaccount:kube-system:ebs-csi-controller-sa"]
    }
    condition {
      test     = "StringEquals"
      variable = "${replace(aws_eks_cluster.sre_eks_cluster.identity[0].oidc[0].issuer, "https://", "")}:aud"
      values   = ["sts.amazonaws.com"]
    }
}
}

################################Create IAM Role for EBS CSI Driver################################
resource "aws_iam_role" "ebs_csi_driver_role" {
  name = "ebs-csi-driver-role"
  assume_role_policy = data.aws_iam_policy_document.ebs_csi_driver_policy.json
}

################################Attach IAM Policy to the Role################################
resource "aws_iam_role_policy_attachment" "ebs_csi_driver_policy_attachment" {
  role       = aws_iam_role.ebs_csi_driver_role.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonEBSCSIDriverPolicy"
}

################################Install EKS CSI Driver################################
resource "aws_eks_addon" "ebs_csi_driver" {
  cluster_name = aws_eks_cluster.sre_eks_cluster.name
  addon_name   = "aws-ebs-csi-driver"
  service_account_role_arn = aws_iam_role.ebs_csi_driver_role.arn
  resolve_conflicts_on_create = "OVERWRITE"
  resolve_conflicts_on_update = "OVERWRITE"
  depends_on = [aws_eks_node_group.sre_eks_node_group, aws_iam_role_policy_attachment.ebs_csi_driver_policy_attachment, aws_iam_openid_connect_provider.eks_oidc_provider]
  }