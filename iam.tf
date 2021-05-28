############################
### IOT Service IAM Role ###
############################
data "aws_iam_policy_document" "iot_assume_role" {
  statement {
    actions = [
      "sts:AssumeRole",
    ]
    principals {
      identifiers = [
        "iot.amazonaws.com",
      ]
      type = "Service"
    }
  }
}

resource "aws_iam_role" "iot_role" {
  name               = "${var.name}-iot-role"
  assume_role_policy = data.aws_iam_policy_document.iot_assume_role.json

  # AWS returns success for IAM change but change is not yet available for a few seconds. Sleep to miss the race condition failure.
  provisioner "local-exec" {
    interpreter = ["bash", "-c"]
    command = "sleep 30"
  }
}

############################
###  IAM for SNS Actions ###
############################
data "aws_iam_policy_document" "sns_publish" {
  count = length(var.sns) != 0 ? 1 : 0
  statement {
    actions = [
      "sns:Publish",
    ]
    resources = var.sns.*.target_arn
    sid       = "SNSPublish"
  }
}

resource "aws_iam_policy" "sns_publish" {
  count  = length(var.sns) != 0 ? 1 : 0
  name   = "${var.name}-sns-publish"
  policy = data.aws_iam_policy_document.sns_publish.0.json
}

resource "aws_iam_role_policy_attachment" "sns_publish" {
  count      = length(var.sns) != 0 ? 1 : 0
  policy_arn = aws_iam_policy.sns_publish.0.arn
  role       = aws_iam_role.iot_role.name
}

#######################################
###  Permissions for Lambda Actions ###
#######################################
data "aws_lambda_function" "lambdas" {
  count         = length(var.lambda)
  function_name = var.lambda[count.index]
}

resource "aws_lambda_permission" "invoke_lambda" {
  count         = length(var.lambda)
  statement_id  = "AllowInvocationFromIOT"
  action        = "lambda:InvokeFunction"
  function_name = var.lambda[count.index]
  principal     = "iot.amazonaws.com"
  source_arn    = aws_iot_topic_rule.rule.arn
}

################################
###  IAM for CW Alarm Action ###
################################
data "aws_iam_policy_document" "cw_alarm" {
  count = length(var.cloudwatch_alarm) != 0 ? 1 : 0
  statement {
    actions = [
      "cloudwatch:SetAlarmState",
    ]
    resources = local.cloudwatch_alarm_arns
    sid       = "CWAlarmSetState"
  }
}

resource "aws_iam_policy" "cw_alarm" {
  count  = length(var.cloudwatch_alarm) != 0 ? 1 : 0
  name   = "${var.name}-cw-alarm"
  policy = data.aws_iam_policy_document.cw_alarm.0.json
}

resource "aws_iam_role_policy_attachment" "cw_alarm" {
  count      = length(var.cloudwatch_alarm) != 0 ? 1 : 0
  policy_arn = aws_iam_policy.cw_alarm.0.arn
  role       = aws_iam_role.iot_role.name
}



################################
###  IAM for CW Metric Action ###
################################
data "aws_iam_policy_document" "cw_metric" {
  count = length(var.cloudwatch_metric) != 0 ? 1 : 0
  statement {
    actions = [
      "cloudwatch:PutMetricData",
    ]
    resources = [
      "*",
    ]
    sid = "CWMetric"
  }
}

resource "aws_iam_policy" "cw_metric" {
  count  = length(var.cloudwatch_metric) != 0 ? 1 : 0
  name   = "${var.name}-cw-metric"
  policy = data.aws_iam_policy_document.cw_metric.0.json
}

resource "aws_iam_role_policy_attachment" "cw_metric" {
  count      = length(var.cloudwatch_metric) != 0 ? 1 : 0
  policy_arn = aws_iam_policy.cw_metric.0.arn
  role       = aws_iam_role.iot_role.name
}




################################
###  IAM for Dynamodb Action ###
################################
data "aws_iam_policy_document" "dynamodb" {
  count = length(var.dynamodb) != 0 ? 1 : 0
  statement {
    actions = [
      "dynamodb:PutItem",
    ]
    resources = local.dynamodb_arns
    sid       = "PutItems"
  }
}

resource "aws_iam_policy" "dynamodb" {
  count  = length(var.dynamodb) != 0 ? 1 : 0
  name   = "${var.name}-dynamodb"
  policy = data.aws_iam_policy_document.dynamodb.0.json
}

resource "aws_iam_role_policy_attachment" "dynamodb" {
  count      = length(var.dynamodb) != 0 ? 1 : 0
  policy_arn = aws_iam_policy.dynamodb.0.arn
  role       = aws_iam_role.iot_role.name
}


#####################################
###  IAM for elasticsearch Action ###
#####################################
data "aws_iam_policy_document" "elasticsearch" {
  count = length(var.elasticsearch) != 0 ? 1 : 0
  statement {
    actions = [
      "es:ESHttpPut",
    ]
    resources = ["arn:aws:es:${data.aws_region.current.name}:${data.aws_caller_identity.current.account_id}:domain/*",
    ]
    sid = "ElasticPut"
  }
}

resource "aws_iam_policy" "elasticsearch" {
  count  = length(var.elasticsearch) != 0 ? 1 : 0
  name   = "${var.name}-elasticsearch"
  policy = data.aws_iam_policy_document.elasticsearch.0.json
}

resource "aws_iam_role_policy_attachment" "elasticsearch" {
  count      = length(var.elasticsearch) != 0 ? 1 : 0
  policy_arn = aws_iam_policy.elasticsearch.0.arn
  role       = aws_iam_role.iot_role.name
}


#########################################
###  Writing Error/Message logs to CW ###
#########################################
data "aws_iam_policy_document" "cloudwatch_logs" {
  count = var.error_logs || var.message_data_logs ? 1 : 0
  statement {
    actions = [
      "logs:CreateLogStream",
      "logs:PutLogEvents",
    ]
    resources = (var.error_logs && var.message_data_logs) ? ["${aws_cloudwatch_log_group.errors_log_group.0.arn}:*",
    "${aws_cloudwatch_log_group.message_data_log_group.0.arn}:*"] : (var.error_logs && ! var.message_data_logs) ? ["${aws_cloudwatch_log_group.errors_log_group.0.arn}:*"] : ["${aws_cloudwatch_log_group.message_data_log_group.0.arn}:*"]
    sid = "AllowErrorOrMessageLogWriting"
  }
}

resource "aws_iam_policy" "cloudwatch_logs" {
  count  = var.error_logs || var.message_data_logs ? 1 : 0
  name   = "${var.name}-cloudwatch-logs"
  policy = data.aws_iam_policy_document.cloudwatch_logs.0.json
}

resource "aws_iam_role_policy_attachment" "cloudwatch_logs" {
  count      = var.error_logs || var.message_data_logs ? 1 : 0
  policy_arn = aws_iam_policy.cloudwatch_logs.0.arn
  role       = aws_iam_role.iot_role.name
}



##########################
###  IAM for S3 Action ###
##########################
data "aws_iam_policy_document" "s3" {
  count = length(var.s3) != 0 ? 1 : 0
  statement {
    actions = [
      "s3:PutObject",
    ]
    resources = local.s3_bucket_arns
    sid       = "S3PutObject"
  }
}

resource "aws_iam_policy" "s3" {
  count  = length(var.s3) != 0 ? 1 : 0
  name   = "${var.name}-s3"
  policy = data.aws_iam_policy_document.s3.0.json
}

resource "aws_iam_role_policy_attachment" "s3" {
  count      = length(var.s3) != 0 ? 1 : 0
  policy_arn = aws_iam_policy.s3.0.arn
  role       = aws_iam_role.iot_role.name
}



###############################################
###  Permissions for sqs  Actions #############
###############################################

data "aws_iam_policy_document" "sqs" {
  count = length(var.sqs) != 0 ? 1 : 0
  statement {
    actions = [
      "sqs:SendMessage",
    ]
    resources = ["arn:aws:sqs:${data.aws_region.current.name}:${data.aws_caller_identity.current.account_id}:*",
    ]
    sid = "SqsSend"
  }
}

resource "aws_iam_policy" "sqs" {
  count  = length(var.sqs) != 0 ? 1 : 0
  name   = "${var.name}-sqs-sendmessage"
  policy = data.aws_iam_policy_document.sqs.0.json
}

resource "aws_iam_role_policy_attachment" "sqs" {
  count      = length(var.sqs) != 0 ? 1 : 0
  policy_arn = aws_iam_policy.sqs.0.arn
  role       = aws_iam_role.iot_role.name
}



###############################################
###  Permissions for kinesis  Actions #############
###############################################

data "aws_iam_policy_document" "kinesis" {
  count = length(var.kinesis) != 0 ? 1 : 0
  statement {
    actions = [
      "kinesis:PutRecord",
    ]
    resources = local.kinesis_arns
    sid       = "KinesisPut"
  }
}

resource "aws_iam_policy" "kinesis" {
  count  = length(var.kinesis) != 0 ? 1 : 0
  name   = "${var.name}-kinesis-put"
  policy = data.aws_iam_policy_document.kinesis.0.json
}

resource "aws_iam_role_policy_attachment" "kinesis" {
  count      = length(var.kinesis) != 0 ? 1 : 0
  policy_arn = aws_iam_policy.kinesis.0.arn
  role       = aws_iam_role.iot_role.name
}


###############################################
###  Permissions for firehose  Actions #############
###############################################

data "aws_iam_policy_document" "firehose" {
  count = length(var.firehose) != 0 ? 1 : 0
  statement {
    actions = [
      "firehose:PutRecord",
    ]
    resources = local.firehose_arns
    sid       = "FirehosePut"
  }
}

resource "aws_iam_policy" "firehose" {
  count  = length(var.firehose) != 0 ? 1 : 0
  name   = "${var.name}-firehose-put-record"
  policy = data.aws_iam_policy_document.firehose.0.json
}

resource "aws_iam_role_policy_attachment" "firehose" {
  count      = length(var.firehose) != 0 ? 1 : 0
  policy_arn = aws_iam_policy.firehose.0.arn
  role       = aws_iam_role.iot_role.name
}


#####################################################
###  Permissions for republish  Actions #############
#####################################################

data "aws_iam_policy_document" "republish" {
  count = length(var.republish) != 0 ? 1 : 0
  statement {
    actions = [
      "iot:Publish",
    ]
    resources = local.republish_arns
    sid = "IotPublish"
  }
}

resource "aws_iam_policy" "republish" {
  count  = length(var.republish) != 0 ? 1 : 0
  name   = "${var.name}-iot-republish"
  policy = data.aws_iam_policy_document.republish.0.json
}

resource "aws_iam_role_policy_attachment" "republish" {
  count      = length(var.republish) != 0 ? 1 : 0
  policy_arn = aws_iam_policy.republish.0.arn
  role       = aws_iam_role.iot_role.name
}
