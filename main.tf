provider "aws" {
  region = "eu-west-3"
}

# Créer un rôle pour Lambda
resource "aws_iam_role" "lambda_exec" {
  name = "lambda_exec_role"
  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [{
      Action = "sts:AssumeRole",
      Effect = "Allow",
      Principal = {
        Service = "lambda.amazonaws.com"
      }
    }]
  })
}

# Attacher une politique d'exécution basique
resource "aws_iam_role_policy_attachment" "lambda_policy" {
  role       = aws_iam_role.lambda_exec.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole"
}

# Préparer le fichier zip de la fonction
data "archive_file" "lambda_zip" {
  type        = "zip"
  source_file = "${path.module}/lambda/main.py"
  output_path = "${path.module}/lambda.zip"
}

# Déployer la fonction Lambda
resource "aws_lambda_function" "hello" {
  function_name = "hello_lambda"
  handler       = "main.lambda_handler"
  runtime       = "python3.11"
  role          = aws_iam_role.lambda_exec.arn
  filename      = data.archive_file.lambda_zip.output_path
  source_code_hash = data.archive_file.lambda_zip.output_base64sha256
}

# URL d'invocation (vérifie dans AWS console ou API Gateway si besoin)
output "lambda_name" {
  value = aws_lambda_function.hello.function_name
}



# Module VPC requis pour EKS
module "vpc" {
  source  = "terraform-aws-modules/vpc/aws"
  version = "5.1.1"

  name = "eks-vpc"
  cidr = "10.0.0.0/16"

  azs             = ["eu-west-3a", "eu-west-3b"]
  public_subnets  = ["10.0.1.0/24", "10.0.2.0/24"]
  enable_dns_hostnames = true

  tags = {
    "kubernetes.io/cluster/mon-cluster-eks" = "shared"
  }
}

# Module EKS minimal
module "eks" {
  source  = "terraform-aws-modules/eks/aws"
  version = "20.8.3"

  cluster_name    = "Cluster_eks"
  cluster_version = "1.32"
  subnet_ids      = module.vpc.public_subnets
  vpc_id          = module.vpc.vpc_id

  eks_managed_node_groups = {
    default = {
      instance_types = ["t3.small"]
      min_size       = 1
      max_size       = 2
      desired_size   = 1
    }
  }
}

output "eks_cluster_name" {
  value = module.eks.cluster_name
}
