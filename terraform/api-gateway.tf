terraform {
}

provider "aws" {}



resource "aws_apigatewayv2_api" "main" {
  name          = "main"
  protocol_type = "HTTP"
}

resource "aws_apigatewayv2_stage" "swagger-ui" {
  api_id = aws_apigatewayv2_api.main.id

  name        = "swagger-ui"
  auto_deploy = true
}

resource "aws_apigatewayv2_stage" "v1" {
  api_id = aws_apigatewayv2_api.main.id

  name        = "v1"
  auto_deploy = true
}

data "aws_vpc" "techchallenge-vpc" {
    filter {
        name   = "tag:Name"
        values = ["techchallenge-vpc"]
    }
}

data "aws_subnets" "private-subnets" {
  filter {
    name   = "vpc-id"
    values = [data.aws_vpc.techchallenge-vpc.id]
  }

  filter {
    name   = "tag:Name"
    values = ["*private*"]
  }
}

resource "aws_security_group" "vpc_link" {
  name   = "vpc-link"
  vpc_id = data.aws_vpc.techchallenge-vpc.id

  egress {
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
  }
}

resource "aws_apigatewayv2_vpc_link" "eks" {
  name               = "eks"
  security_group_ids = [aws_security_group.vpc_link.id]
  subnet_ids = data.aws_subnets.private-subnets.ids
}

data "aws_lb" "java-app-service" {
    tags = {
        "kubernetes.io/service-name": "default/java-app-service"
    }
}
resource "aws_apigatewayv2_integration" "eks" {
  api_id = aws_apigatewayv2_api.main.id

#   integration_uri    = "arn:aws:elasticloadbalancing:us-east-1:105833672688:listener/net/a85b7efaa5950471facb7d0b8e0e96bb/efa74dfcb600a49b/c6cb48fdcfdb7556"
  integration_uri = "arn:aws:elasticloadbalancing:us-east-1:105833672688:listener/net/a131fd50ed7d0493cae86b8913f43198/78c05c8f3df617e4/7cc354859a5bd697"
  integration_type   = "HTTP_PROXY"
  integration_method = "ANY"
  connection_type    = "VPC_LINK"
  connection_id      = aws_apigatewayv2_vpc_link.eks.id
}


resource "aws_apigatewayv2_route" "get_echo" {
  api_id = aws_apigatewayv2_api.main.id

  route_key = "ANY /{proxy+}"
  target    = "integrations/${aws_apigatewayv2_integration.eks.id}"
}
