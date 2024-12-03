resource "aws_lambda_function" "automation-ecs-start-stop" {
  #checkov:skip=CKV_AWS_272: "Ensure AWS Lambda function is configured to validate code-signing"
  #checkov:skip=CKV_AWS_116: "Ensure that AWS Lambda function is configured for a Dead Letter Queue(DLQ)"
  #checkov:skip=CKV_AWS_117: "Ensure that AWS Lambda function is configured inside a VPC" #
  #checkov:skip=CKV_AWS_50: "X-ray tracing is enabled for Lambda"
  #checkov:skip=CKV_AWS_115: "Ensure that AWS Lambda function is configured for function-level concurrent execution limit"

  function_name = "automation-ecs-start-stop"
  handler       = "automation_ecs_start_stop.lambda_handler"
  runtime       = "python3.13"
  filename      = "./code/automation_ecs_start_stop.zip"
  role          = aws_iam_role.automation-ecs-start-stop.arn
  kms_key_arn   = data.aws_kms_key.lambda_key.arn
  timeout =  900
  source_code_hash = filebase64sha256("./code/automation_ecs_start_stop.zip")

  depends_on = [aws_iam_role.automation-ecs-start-stop, aws_cloudwatch_log_group.automation-ecs-start-stop]

  environment {
    variables = {
      sns_alert = aws_sns_topic.automation-alarm.arn
    }
  }
}

resource "aws_cloudwatch_log_group" "automation-ecs-start-stop" {
  #checkov:skip=CKV_AWS_338: "Ensure CloudWatch log groups retains logs for at least 1 year"
  name              = "/aws/lambda/automation-ecs-start-stop"
  retention_in_days = 14
}
