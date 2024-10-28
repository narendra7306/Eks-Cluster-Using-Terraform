#Set up the first resource for the IAM role. This ensures that the role has access to EKS
resource "aws_iam_role" "eks-iam-role" {
 name = "srdemo-eks-iam-role"

 path = "/"

 assume_role_policy = <<EOF
{
 "Version": "2012-10-17",
 "Statement": [
  {
   "Effect": "Allow",
   "Principal": {
    "Service": "eks.amazonaws.com"
   },
   "Action": "sts:AssumeRole"
  }
 ]
}
EOF

}

#Once the role is created, attach these two policies to it
resource "aws_iam_role_policy_attachment" "AmazonEKSClusterPolicy" {
 policy_arn = "arn:aws:iam::aws:policy/AmazonEKSClusterPolicy"
 role    = aws_iam_role.eks-iam-role.name
}
resource "aws_iam_role_policy_attachment" "AmazonEC2ContainerRegistryReadOnly-EKS" {
 policy_arn = "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryReadOnly"
 role    = aws_iam_role.eks-iam-role.name
}

#Once the policies are attached, create the EKS cluster
resource "aws_eks_cluster" "demo-eks" {
 name = "demo-cluster"
 role_arn = aws_iam_role.eks-iam-role.arn
 version = "1.29"

 vpc_config {
  subnet_ids = ["subnet-0535e6756c23986c3", "subnet-0ef4b7e943879c148"]
  security_group_ids = ["sg-06c34e3947ca8fd3d"]
 }

 depends_on = [
  aws_iam_role.eks-iam-role,
 ]
}

#Set up an IAM role for the worker nodes
resource "aws_iam_role" "workernodes" {
  name = "demo-node-group-example"
 
  assume_role_policy = jsonencode({
   Statement = [{
    Action = "sts:AssumeRole"
    Effect = "Allow"
    Principal = {
     Service = "ec2.amazonaws.com"
    }
   }]
   Version = "2012-10-17"
  })
 }
 
 resource "aws_iam_role_policy_attachment" "AmazonEKSWorkerNodePolicy" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSWorkerNodePolicy"
  role    = aws_iam_role.workernodes.name
 }
 
 resource "aws_iam_role_policy_attachment" "AmazonEKS_CNI_Policy" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKS_CNI_Policy"
  role    = aws_iam_role.workernodes.name
 }
 
 resource "aws_iam_role_policy_attachment" "EC2InstanceProfileForImageBuilderECRContainerBuilds" {
  policy_arn = "arn:aws:iam::aws:policy/EC2InstanceProfileForImageBuilderECRContainerBuilds"
  role    = aws_iam_role.workernodes.name
 }
 
 resource "aws_iam_role_policy_attachment" "AmazonEC2ContainerRegistryReadOnly" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryReadOnly"
  role    = aws_iam_role.workernodes.name
 }
#Step 7. The last bit of code is to create the worker nodes. For testing purposes, use just one worker node in the scaling_config configuration. In production, follow best practices and use at least three worker nodes.

 resource "aws_eks_node_group" "worker-node-group" {
  cluster_name  = aws_eks_cluster.demo-eks.name
  node_group_name = "demo-workernodes"
  node_role_arn  = aws_iam_role.workernodes.arn
  subnet_ids = ["subnet-0535e6756c23986c3", "subnet-0ef4b7e943879c148"]
  instance_types = ["t3.small"]
  
  scaling_config {
   desired_size = 1
   max_size   = 2
   min_size   = 1
  }
 
  depends_on = [
   aws_iam_role_policy_attachment.AmazonEKSWorkerNodePolicy,
   aws_iam_role_policy_attachment.AmazonEKS_CNI_Policy,
   aws_iam_role_policy_attachment.AmazonEC2ContainerRegistryReadOnly,
  ]
 }


