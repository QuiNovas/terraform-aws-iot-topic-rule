locals {
  cloudwatch_alarm_arns = formatlist("arn:aws:cloudwatch:${data.aws_region.current.name}:${data.aws_caller_identity.current.account_id}:alarm/%s", var.cloudwatch_alarm.*.alarm_name)
  dynamodb_arns         = formatlist("arn:aws:dynamodb:${data.aws_region.current.name}:${data.aws_caller_identity.current.account_id}:table/%s", var.dynamodb.*.table_name)
  s3_bucket_arns        = formatlist("arn:aws:s3:::%s/*", var.s3.*.bucket_name)
}