variable "name" {
  description = "Name of the rule, used as prefix for other resources"
  type        = string
  default     = true
}

variable "description" {
  description = "The description of the rule"
  type        = string
  default     = ""
}

variable "enabled" {
  description = "Specifies whether the rule is enabled"
  type        = string
  default     = true
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

variable "sns" {
  description = "SNS action, message_format, target_arn are supported arguments"
  type = list(object({
    message_format = string
    target_arn     = string
  }))
  default = []
}

variable "lambda" {
  description = "Lambda action, list of function_names"
  type        = list(string)
  default     = []
}