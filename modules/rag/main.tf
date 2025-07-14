resource "random_id" "bucket_id" {
  byte_length = 4
}

resource "aws_s3_bucket" "docs" {
  bucket        = "rag-${var.environment}-docs-${random_id.bucket_id.hex}"
  force_destroy = true

  tags = {
    Environment = var.environment
    Purpose     = "RAG document storage"
  }
}

resource "aws_dynamodb_table" "embeddings" {
  name         = "rag-${var.environment}-embeddings"
  billing_mode = "PAY_PER_REQUEST"
  hash_key     = "id"

  attribute {
    name = "id"
    type = "S"
  }

  tags = {
    Environment = var.environment
    Purpose     = "RAG embedding store"
  }
}

resource "aws_iam_role" "lambda_exec" {
  name = "rag-${var.environment}-lambda-exec"

  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [{
      Effect    = "Allow"
      Principal = { Service = "lambda.amazonaws.com" }
      Action    = "sts:AssumeRole"
    }]
  })

  tags = {
    Environment = var.environment
  }
}

resource "aws_iam_role_policy_attachment" "lambda_basic_execution" {
  role       = aws_iam_role.lambda_exec.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole"
}

resource "aws_lambda_function" "rag_handler" {
  function_name = "rag-${var.environment}-handler"
  role          = aws_iam_role.lambda_exec.arn
  runtime       = "python3.11"
  handler       = "main.lambda_handler"
  timeout       = 15
  memory_size   = 256

  filename         = var.lambda_package_path
  source_code_hash = filebase64sha256(var.lambda_package_path)

  tags = {
    Environment = var.environment
  }
}

resource "aws_api_gateway_rest_api" "rag_api" {
  name = "rag-${var.environment}-api"

  tags = {
    Environment = var.environment
  }
}

resource "aws_api_gateway_resource" "query" {
  rest_api_id = aws_api_gateway_rest_api.rag_api.id
  parent_id   = aws_api_gateway_rest_api.rag_api.root_resource_id
  path_part   = "query"
}

resource "aws_api_gateway_method" "get_query" {
  rest_api_id     = aws_api_gateway_rest_api.rag_api.id
  resource_id     = aws_api_gateway_resource.query.id
  http_method     = "GET"
  authorization   = "NONE"
  api_key_required = true
}

resource "aws_api_gateway_integration" "lambda_query" {
  rest_api_id             = aws_api_gateway_rest_api.rag_api.id
  resource_id             = aws_api_gateway_resource.query.id
  http_method             = aws_api_gateway_method.get_query.http_method
  integration_http_method = "POST"
  type                    = "AWS_PROXY"
  uri                     = aws_lambda_function.rag_handler.invoke_arn
}

resource "aws_lambda_permission" "apigw_invoke_lambda" {
  statement_id  = "AllowAPIGatewayInvoke"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.rag_handler.function_name
  principal     = "apigateway.amazonaws.com"
  source_arn    = "${aws_api_gateway_rest_api.rag_api.execution_arn}/*/*"
}

resource "aws_api_gateway_deployment" "deployment" {
  depends_on = [
    aws_api_gateway_integration.lambda_query,
    aws_api_gateway_method.get_query,
  ]

  rest_api_id = aws_api_gateway_rest_api.rag_api.id

  triggers = {
    redeployment = sha1(jsonencode({
      method_id     = aws_api_gateway_method.get_query.id
      integration_id = aws_api_gateway_integration.lambda_query.id
      api_key_req   = aws_api_gateway_method.get_query.api_key_required
    }))
  }

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_api_gateway_stage" "stage" {
  rest_api_id   = aws_api_gateway_rest_api.rag_api.id
  stage_name    = "prod"
  deployment_id = aws_api_gateway_deployment.deployment.id

  tags = {
    Environment = var.environment
  }
}

resource "aws_api_gateway_api_key" "api_key" {
  name    = "rag-${var.environment}-api-key"
  enabled = true
}

resource "aws_api_gateway_usage_plan" "usage_plan" {
  name = "rag-${var.environment}-usage-plan"

  api_stages {
    api_id = aws_api_gateway_rest_api.rag_api.id
    stage  = aws_api_gateway_stage.stage.stage_name
  }
}

resource "aws_api_gateway_usage_plan_key" "usage_plan_key" {
  key_id        = aws_api_gateway_api_key.api_key.id
  key_type      = "API_KEY"
  usage_plan_id = aws_api_gateway_usage_plan.usage_plan.id
}
