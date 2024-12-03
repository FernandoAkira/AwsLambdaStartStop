# Criar o tópico SNS
resource "aws_sns_topic" "automation-alarm" {
  name = "automation-alarm"
}

# Criar a assinatura por e-mail
resource "aws_sns_topic_subscription" "automation-alarm" {
  topic_arn = aws_sns_topic.automation-alarm.arn
  protocol  = "email"
  endpoint  = var.sns_email
}

resource "aws_ssm_parameter" "automation-alarm" {
   #checkov:skip=CKV2_AWS_34: "AWS SSM Parameter should be Encrypted"
  name  = "/meu_projeto/sns/automation-alarm"
  type  = "String"
  value = aws_sns_topic.automation-alarm.arn 
}