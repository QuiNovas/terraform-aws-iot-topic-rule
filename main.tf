resource "aws_iot_topic_rule" "rule" {
  name        = var.name
  description = var.description
  enabled     = var.enabled
  sql         = var.sql_query
  sql_version = var.sql_version

  dynamic "sns" {
    for_each = var.sns

    content {
      message_format = sns.value.message_format
      role_arn       = aws_iam_role.iot_role.arn
      target_arn     = sns.value.target_arn
    }
  }

  dynamic "lambda" {
    for_each = data.aws_lambda_function.lambdas

    content {
      function_arn = lambda.value.arn #lambda.value.function_arn
    }
  }
}