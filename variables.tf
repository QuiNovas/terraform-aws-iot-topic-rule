variable "cloudwatch_alarm" {
  description = "CW Alarm action"
  type = list(object({
    alarm_name   = string
    state_reason = string
    state_value  = string
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

variable "enabled" {
  description = "Specifies whether the rule is enabled"
  type        = string
  default     = true
}

variable "lambda" {
  description = "Lambda action. List of function_names"
  type        = list(string)
  default     = []
}

variable "name" {
  description = "Name of the rule, used as prefix for other resources"
  type        = string
  default     = true
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