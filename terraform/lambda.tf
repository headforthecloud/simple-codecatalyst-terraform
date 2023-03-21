data "archive_file" "lambda_function_zip" {
  type        = "zip"
  source_file = "../source/lambda_function.py"
  output_path = "../source/lambda_function.zip"
}

# Generate a random suffix for our lambda function.
resource "random_id" "id" {
	  byte_length = 8
}

resource "aws_lambda_function" "lambda_function" {
  function_name                  = "test-lambda-function-${random_id.id.hex}"
  role                           = aws_iam_role.lambda_execution_role.arn
  description                    = "Demo Lambda"
  filename                       = data.archive_file.lambda_function_zip.output_path
  source_code_hash               = data.archive_file.lambda_function_zip.output_base64sha256
  handler                        = "lambda_function.lambda_handler"
  runtime                        = "python3.9"
}

resource "aws_cloudwatch_log_group" "lambda_log_group" {
  name = "/aws/lambda/${aws_lambda_function.lambda_function.function_name}"
  retention_in_days = 1
}

resource "aws_lambda_function_url" "lambda_url" {
  function_name      = aws_lambda_function.lambda_function.function_name
  authorization_type = "NONE"
}