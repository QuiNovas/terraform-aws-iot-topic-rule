# terraform-aws-iot-topic-rule

This module is used to create a aws iot rule with actions. It dynamically creates IAM permissions required by the action

**Note:**
Not all actions/errors are supported by [Terraform] (https://www.terraform.io/docs/providers/aws/r/iot_topic_rule.html) when this was written. 

**Supported Actions**
cloudwatch_alarm
lambda
s3
sns

## Usage

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
      alarm_name="test-iot-tf-module"
      alarm_arn="arn:aws:cloudwatch:us-east-1:111222333444:alarm:my-alarm-1"
      state_reason="iotRule1"
      state_value="OK"
    }
   ]
}
```

## Authors

Module is maintained by [QuiNovas](https://github.com/QuiNovas)

## License

Apache License, Version 2.0, January 2004 (http://www.apache.org/licenses/). See LICENSE for full details.