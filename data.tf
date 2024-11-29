data "aws_caller_identity" "current" {}

data "aws_kms_key" "lambda_key" {
  key_id = var.kms_for_lambda
}

data "aws_kms_key" "cloudwatch_key" {
  key_id = var.kms_for_cloudwatch
}
