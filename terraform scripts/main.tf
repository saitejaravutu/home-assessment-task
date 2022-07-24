provider "aws" {
    access_key = ""
    secret_key = ""
    region = "ap-south-1"
}

data "aws_availability_zones" "available" {
state = "available"
}
data "aws_vpc" "mum-akscluster-vpc" {
  cidr_block = "10.35.0.0/16"


}

data "aws_subnet" "mum-eks-private-subnet" {
  cidr_block        = "10.35.0.0/24"
  vpc_id            = "${data.aws_vpc.mum-akscluster-vpc.id}"


}

data "aws_subnet" "mum-eks-public-subnet" {

  cidr_block        = "10.35.1.0/24"
  vpc_id            = "${data.aws_vpc.mum-akscluster-vpc.id}"


}


data "aws_iam_role" "role" {
  name = "eksClusterRole"

 }
data "aws_iam_role" "role2"{
  name = "NodeInstanceRole"
  }

resource "aws_eks_cluster" "eksClusterRole" {
  name            = "terraform-eks-demo"
  role_arn        = "${data.aws_iam_role.role.arn}"

  vpc_config {

   subnet_ids         = ["${data.aws_subnet.mum-eks-private-subnet.id}","${data.aws_subnet.mum-eks-public-subnet.id}"]

  }

}

resource "aws_eks_node_group" "example"{
  cluster_name    = aws_eks_cluster.eksClusterRole.name
  node_group_name = "agentpool"
  node_role_arn   = "${data.aws_iam_role.role2.arn}"
  subnet_ids         = ["${data.aws_subnet.mum-eks-private-subnet.id}","${data.aws_subnet.mum-eks-public-subnet.id}"] 
  ami_type = "AL2_x86_64"
  disk_size = "20"
  instance_types = ["t3.medium"]
 capacity_type = "ON_DEMAND"

  scaling_config {
  desired_size = 1
  min_size     = 1
  max_size     = 1
  }
  tags = {
    Environment = "test"
  }
  }

