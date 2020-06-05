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


  dynamic "cloudwatch_metric" {
    for_each = var.cloudwatch_metric

    content {
      metric_name      = cloudwatch_metric.value.metric_name
      role_arn         = aws_iam_role.iot_role.arn
      metric_namespace = cloudwatch_metric.value.metric_namespace
      metric_timestamp = lookup(cloudwatch_metric.value, "metric_timestamp", null)
      metric_unit      = cloudwatch_metric.value.metric_unit
      metric_value     = cloudwatch_metric.value.metric_value
    }
  }

  description = var.description

  dynamic "dynamodb" {
    for_each = var.dynamodb

    content {
      hash_key_field  = dynamodb.value.hash_key_field
      hash_key_type   = lookup(dynamodb.value, "hash_key_type", null)
      hash_key_value  = dynamodb.value.hash_key_value
      payload_field   = lookup(dynamodb.value, "payload_field", null)
      range_key_field = lookup(dynamodb.value, "range_key_field", null)
      range_key_type  = lookup(dynamodb.value, "range_key_type", null)
      range_key_value = lookup(dynamodb.value, "range_key_value", null)
      role_arn        = aws_iam_role.iot_role.arn
      table_name      = dynamodb.value.table_name
    }
  }


  dynamic "elasticsearch" {
    for_each = var.elasticsearch

    content {
      endpoint = elasticsearch.value.endpoint
      role_arn = aws_iam_role.iot_role.arn
      id       = elasticsearch.value.id
      index    = elasticsearch.value.index
      type     = elasticsearch.value.type
    }
  }

  enabled = var.enabled


  dynamic "firehose" {
    for_each = var.firehose

    content {
      delivery_stream_name = firehose.value.delivery_stream_name
      role_arn             = aws_iam_role.iot_role.arn
      separator            = lookup(firehose.value, "separator", null)
    }
  }

  dynamic "kinesis" {
    for_each = var.kinesis

    content {
      partition_key = lookup(kinesis.value, "partition_key", null)
      role_arn      = aws_iam_role.iot_role.arn
      stream_name   = kinesis.value.stream_name
    }
  }

  dynamic "lambda" {
    for_each = data.aws_lambda_function.lambdas

    content {
      function_arn = lambda.value.arn
    }
  }

  name = var.name

  dynamic "republish" {
    for_each = var.republish

    content {
      topic    = republish.value.topic
      role_arn = aws_iam_role.iot_role.arn
    }
  }

  dynamic "s3" {
    for_each = var.s3

    content {
      bucket_name = s3.value.bucket_name
      key         = s3.value.key
      role_arn    = aws_iam_role.iot_role.arn
    }
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


  dynamic "sqs" {
    for_each = var.sqs

    content {
      queue_url  = sqs.value.queue_url
      role_arn   = aws_iam_role.iot_role.arn
      use_base64 = sqs.value.use_base64
    }
  }

}

resource "aws_cloudwatch_log_group" "errors_log_group" {
  count             = var.error_logs ? 1 : 0
  name              = "/aws/iot/rule/${var.name}/errors"
  retention_in_days = 7
}

resource "aws_cloudwatch_log_group" "message_data_log_group" {
  count             = var.message_data_logs ? 1 : 0
  name              = "/aws/iot/rule/${var.name}/message-data"
  retention_in_days = 7
}