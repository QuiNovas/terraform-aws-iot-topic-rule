resource "aws_iot_topic_rule" "rule" {
  dynamic "cloudwatch_alarm" {
    for_each = var.cloudwatch_alarm

    content {
      alarm_name   = cloudwatch_alarm.value.alarm_name
      role_arn     = aws_iam_role.iot_role.arn
      state_reason = cloudwatch_alarm.value.state_reason
      state_value  = cloudwatch_alarm.value.state_value
    }
  }
  
  description = var.description
  enabled     = var.enabled

  dynamic "lambda" {
    for_each = data.aws_lambda_function.lambdas

    content {
      function_arn = lambda.value.arn
    }
  }

  name = var.name

  dynamic "s3" {
    for_each = var.s3

    content {
      bucket_name = s3.value.bucket_name
      key         = s3.value.key
      role_arn    = aws_iam_role.iot_role.arn
    }

    dynamic "sns" {
      for_each = var.sns

      content {
        message_format = sns.value.message_format
        role_arn       = aws_iam_role.iot_role.arn
        target_arn     = sns.value.target_arn
      }
    }

    sql         = var.sql_query
    sql_version = var.sql_version

  }
}