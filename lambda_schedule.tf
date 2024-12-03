resource "aws_scheduler_schedule" "ecs-start-8-20" {
  #checkov:skip=CKV_AWS_297: "Ensure EventBridge Scheduler Schedule uses Customer Managed Key (CMK)"
  name                         = "ecs-start-8-20"
  schedule_expression          = "cron(0 8 ? * mon-fri *)"
  schedule_expression_timezone = "America/Sao_Paulo"
  flexible_time_window {
    mode = "OFF"
  }
  target {
    arn      = aws_lambda_function.automation-ecs-start-stop.arn
    role_arn = aws_iam_role.automation-ecs-start-stop.arn
    input = jsonencode({
      action    = "start"
      tag_value = "8-20"
    })
  }
}

resource "aws_scheduler_schedule" "ecs-desliga-8-20" {
  #checkov:skip=CKV_AWS_297: "Ensure EventBridge Scheduler Schedule uses Customer Managed Key (CMK)"
  name                         = "ecs-stop-8-20"
  schedule_expression          = "cron(0 20 ? * mon-fri *)"
  schedule_expression_timezone = "America/Sao_Paulo"
  flexible_time_window {
    mode = "OFF"
  }
  target {
    arn      = aws_lambda_function.automation-ecs-start-stop.arn
    role_arn = aws_iam_role.automation-ecs-start-stop.arn
    input = jsonencode({
      action    = "stop"
      tag_value = "8-20"
    })
  }
}
