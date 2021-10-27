terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 3.48.0"
    }
    random = {
      source  = "hashicorp/random"
      version = "~> 3.1.0"
    }
    archive = {
      source  = "hashicorp/archive"
      version = "~> 2.2.0"
    }
  }

  required_version = "~> 1.0"
}

provider "aws" {
  region = var.aws_region
}

resource "random_pet" "lambda_bucket_name" {
  prefix = "first-lambda-golang-functions"
  length = 3
}

resource "aws_s3_bucket" "lambda_bucket" {
  bucket = random_pet.lambda_bucket_name.id

  acl = "private"
  force_destroy = true
}

data "archive_file" "golang_function" {
  type = "zip"

  source_dir = "${path.module}/bin"
  output_path = "${path.module}/golang-func.zip"
}

resource "aws_s3_bucket_object" "golang_function" {
  bucket = aws_s3_bucket.lambda_bucket.id

  key = "golang-func.zip"
  source = data.archive_file.golang_function.output_path

  etag = filemd5(data.archive_file.golang_function.output_path)
}

resource "aws_lambda_function" "golang_lambda" {
  function_name = "helloGo"

  s3_bucket = aws_s3_bucket.lambda_bucket.id
  s3_key = aws_s3_bucket_object.golang_function.key

  runtime = "go1.x"
  handler = "main"

  source_code_hash = data.archive_file.golang_function.output_base64sha256

  role = aws_iam_role.lambda_exec.arn
}

resource "aws_cloudwatch_log_group" "golang_lambda" {
  name = "/aws/lambda/${aws_lambda_function.golang_lambda.function_name}"

  retention_in_days = 30
}

resource "aws_iam_role" "lambda_exec" {
  name = "severless_lambda"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Action = "sts:AssumeRole"
      Effect = "Allow"
      Sid    = ""
      Principal = {
        Service = "lambda.amazonaws.com"
      }
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "lambda_policy" {
  role       = aws_iam_role.lambda_exec.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole"
}


// 1분마다 호출하는 스케줄러 생성
resource "aws_cloudwatch_event_rule" "every_one_minute" {
  name = "every-one-minute"
  description = "Fires every one minutes"
  schedule_expression = "rate(1 minute)"
}

resource "aws_cloudwatch_event_target" "call_gofunc_every_one_minute" {
  rule = aws_cloudwatch_event_rule.every_one_minute.name
  target_id = aws_lambda_function.golang_lambda.id
  arn = aws_lambda_function.golang_lambda.arn
}

resource "aws_lambda_permission" "allow_cloudwatch_to_call_lambda" {
  statement_id = "AllowExecutionFromCloudWatch"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.golang_lambda.function_name
  principal = "events.amazonaws.com"
  source_arn = aws_cloudwatch_event_rule.every_one_minute.arn
}