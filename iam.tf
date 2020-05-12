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
  name   = "sns-publish"
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
    resources = var.cloudwatch_alarm.*.alarm_arn
    sid       = "CWAlarmSetState"
  }
}

resource "aws_iam_policy" "cw_alarm" {
  count  = length(var.cloudwatch_alarm) != 0 ? 1 : 0
  name   = "cw-alarm"
  policy = data.aws_iam_policy_document.cw_alarm.0.json
}

resource "aws_iam_role_policy_attachment" "cw_alarm" {
  count      = length(var.cloudwatch_alarm) != 0 ? 1 : 0
  policy_arn = aws_iam_policy.cw_alarm.0.arn
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
  name   = "s3"
  policy = data.aws_iam_policy_document.s3.0.json
}

resource "aws_iam_role_policy_attachment" "s3" {
  count      = length(var.s3) != 0 ? 1 : 0
  policy_arn = aws_iam_policy.s3.0.arn
  role       = aws_iam_role.iot_role.name
}