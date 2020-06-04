# terraform-aws-iot-topic-rule

This module is used to create a aws iot rule with actions. It dynamically creates IAM permissions required by the action

**Note:**
Not all actions/errors are supported by [Terraform] (https://www.terraform.io/docs/providers/aws/r/iot_topic_rule.html) when this was written. 

**Supported Actions**
* cloudwatch_alarm
* cloudwatch_metric
* dynamodb
* elasticsearch
* firehose
* kinesis
* lambda
* republish
* s3
* sns
* cloudwatch_logs (Only IAM and Log groups are created, Action is not yet supported)

## Usage
* Notifying SNSInvoking Lambda, CW alarm actions

```hcl
module "iot_rule" {
  name        = "iotTestRule"
  description = "Rule created by TF module"
  sql_query   = "select * from \"mytopic/test\""
  source      = "Quinovas/terraform-aws-iot-topic-rule/aws"

  sns = [
    {
      message_format = "RAW"
      target_arn     = "arn:aws:sns:us-east-1:111222333444:sns-topic"
    }
  ]

  lambda = ["my-function-1", "my-function-2"]

  cloudwatch_alarm = [
    {
      alarm_name   = "iot-alarm"
      state_reason = "iotRule1"
      state_value  = "OK"
    }
   ]
}
```
* Inserting message data to Dynamodb table, Cloudwatch and writing Errors to Cloudwatch
```hcl
module "iot_rule" {
  name        = "iotTestRule"
  description = "Rule created by TF module"
  sql_query   = "select * from \"mytopic/test\""
  source      = "Quinovas/terraform-aws-iot-topic-rule/aws"

  message_data_logs = true
  error_logs        = true

  dynamodb = [{
    hash_key_field  = "message"
    hash_key_type   = null
    hash_key_value  = "$message"
    payload_field   = "Payload"
    range_key_field = null
    range_key_type  = null
    range_key_value = null
    table_name      = "test-iot"
  }]
}
```
*  CW metric,elasticsearch,firehose,kinesis and republish actions
```hcl
module "iot_rule" {
  name        = "iotTestRule"
  description = "Rule created by TF module"
  sql_query   = "select * from \"mytopic/test\""
  source      = "Quinovas/terraform-aws-iot-topic-rule/aws"

  cloudwatch_metric = [{
      metric_name      = "Buffers"
      metric_namespace = "TestNamespace"
      metric_timestamp = null
      metric_unit      = "Bytes"
      metric_value     = 231434333
  }]

  elasticsearch = [{
    endpoint     = "https://test-wxzt4lsonb6xw26r6g56q.us-east-1.es.amazonaws.com"  #url of the elasticsearch
    id           = "IotTest"
    index        = "abc"
    type         = "def"
  }]

  firehose = [{
    delivery_stream_name = "test-firehose"
    separator = null
  }]

  kinesis = [{
    partition_key = null
    stream_name = "test-kinesis"
  }]

  republish =[{
    topic = "abcd"
  }]
}
```

## Authors

Module is maintained by [QuiNovas](https://github.com/QuiNovas)

## License

Apache License, Version 2.0, January 2004 (http://www.apache.org/licenses/). See LICENSE for full details.