variable "cloudwatch_alarm" {
  description = "CW Alarm action"
  type = list(object({
    alarm_name   = string
    state_reason = string
    state_value  = string
  }))
  default = []
}

variable "cloudwatch_metric" {
  description = "CW Metric action"
  type = list(object({
    metric_name      = string
    metric_namespace = string
    metric_timestamp = string
    metric_unit      = string
    metric_value     = number
  }))
  default = []
}

variable "description" {
  description = "The description of the rule"
  type        = string
  default     = ""
}

variable "dynamodb" {
  description = "CW Alarm action"
  type = list(object({
    hash_key_field  = string
    hash_key_type   = string
    hash_key_value  = string
    payload_field   = string
    range_key_field = string
    range_key_type  = string
    range_key_value = string
    table_name      = string
  }))
  default = []
}

variable "elasticsearch" {
  description = "elasticsearch action,endpoint,id,index,type"
  type = list(object({
    endpoint = string
    id       = string
    index    = string
    type     = string
  }))
  default = []
}

variable "enabled" {
  description = "Specifies whether the rule is enabled"
  type        = string
  default     = true
}

variable "error_logs" {
  description = "Enable logging of errors to Cloudwatch"
  type        = string
  default     = true
}

variable "firehose" {
  description = "kinesis action. delivery_stream_name and separator"
  type = list(object({
    delivery_stream_name = string
    separator            = string
  }))
  default = []
}

variable "kinesis" {
  description = "kinesis action. partition_key and stream_name"
  type = list(object({
    partition_key = string
    stream_name   = string
  }))
  default = []
}

variable "lambda" {
  description = "Lambda action. List of function_names"
  type        = list(string)
  default     = []
}

variable "message_data_logs" {
  description = "write message data to Cloudwatch"
  type        = string
  default     = false
}

variable "name" {
  description = "Name of the rule, also used as prefix for other resources"
  type        = string
}

variable "republish" {
  description = "publish to a topic"
  type = list(object({
    topic = string
  }))
  default = []
}

variable "s3" {
  description = "CW Alarm action"
  type = list(object({
    bucket_name = string
    key         = string
  }))
  default = []
}

variable "sns" {
  description = "SNS action. message_format, target_arn are supported arguments"
  type = list(object({
    message_format = string
    target_arn     = string
  }))
  default = []
}

variable "sql_query" {
  description = "The SQL statement used to query the topic"
  type        = string
}

variable "sql_version" {
  description = "The version of the SQL rules engine to use when evaluating the rule"
  type        = string
  default     = "2016-03-23"
}

variable "sqs" {
  description = "sqs action. queue url and use_base64 are supported arguments"
  type = list(object({
    queue_url  = string
    use_base64 = bool
  }))
  default = []
}