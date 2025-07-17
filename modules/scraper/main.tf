resource "aws_iam_role" "scraper_lambda_role" {
  name = "scraper_lambda_role"
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

resource "aws_iam_policy" "scraper_s3_policy" {
  name = "scraper_s3_policy"
  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Effect = "Allow",
        Action = [
          "s3:PutObject"
        ],
        Resource = "arn:aws:s3:::${var.s3_bucket_name}/*"
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "scraper_s3_attach" {
  role       = aws_iam_role.scraper_lambda_role.name
  policy_arn = aws_iam_policy.scraper_s3_policy.arn
}

resource "aws_lambda_function" "scraper_lambda" {
  filename         = var.lambda_scraper_package_path
  function_name    = "scraper"
  role             = aws_iam_role.scraper_lambda_role.arn
  handler          = "scraper.lambda_handler"
  runtime          = "python3.11"
  source_code_hash = filebase64sha256(var.lambda_scraper_package_path)

  environment {
    variables = {
      S3_BUCKET = var.s3_bucket_name
    }
  }
}
