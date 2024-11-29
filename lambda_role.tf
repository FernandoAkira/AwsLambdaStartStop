data "aws_iam_policy_document" "automation-ecs-start-stop" {
  statement {
    sid = "PutLog"
    actions = [
      "logs:CreateLogStream",
      "logs:PutLogEvents",
      "logs:CreateLogGroup",
    ]
    resources = [
      "${aws_cloudwatch_log_group.automation-ecs-start-stop.arn}:*",
    ]
  }
    statement {
    sid = "PutSNS"
    actions = [
      "sns:Publish",
    ]
    resources = ["${aws_sns_topic.automation-alarm.arn}"]
  }

      statement {
    sid = "kms"
    actions = [
        "kms:Decrypt",
        "kms:GenerateDataKey*",
        "kms:DescribeKey"
    ]
    resources = ["${data.aws_kms_key.lambda_key.arn}"]
  }
    
    statement {
    sid = "ecsservice"
    actions = [
                "ecs:UpdateService",
                "ecs:DescribeServices",
                "ecs:ListTagsForResource"
    ]
    resources = ["arn:aws:ecs:*:${data.aws_caller_identity.current.account_id}:*"]
  }

  statement {
    sid = "ecscluster"
    actions = [
                "ecs:DescribeClusters",
                "ecs:ListTagsForResource"
    ]
    resources = ["arn:aws:ecs:*:${data.aws_caller_identity.current.account_id}:*"]
  }


  statement {
    sid = "allowLambdaExecutionBySchedule"
    actions = [
      "lambda:InvokeFunction"
    ]
    resources = [
      aws_lambda_function.automation-ecs-start-stop.arn,
    ]
  }

}

resource "aws_iam_policy" "automation-ecs-start-stop" {
  name   = "lambda-policy-automation_ecs_onoff"
  path   = "/"
  policy = data.aws_iam_policy_document.automation-ecs-start-stop.json
}

resource "aws_iam_role" "automation-ecs-start-stop" {
  name   = "lambda-role-automation-ecs-start-stop"
  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Action = "sts:AssumeRole",
        Effect = "Allow",
        Principal = {
          Service = "lambda.amazonaws.com",
        },
      },
      {
        Action = "sts:AssumeRole",
        Effect = "Allow",
        Principal = {
          Service = "scheduler.amazonaws.com",
        },
      },
    ],
  })
}

resource "aws_iam_role_policy_attachment" "automation-ecs-start-stop" {
  role       = aws_iam_role.automation-ecs-start-stop.name
  policy_arn = aws_iam_policy.automation-ecs-start-stop.arn
}
