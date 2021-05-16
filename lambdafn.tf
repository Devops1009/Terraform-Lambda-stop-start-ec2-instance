
data "archive_file" "zip" {
  type = "zip"
  source_file = "${var.file1}"
  output_path = "${var.file1}.zip"
}




resource "aws_lambda_function" "test_lambda" {
  filename      = "${data.archive_file.zip.output_path}"
  function_name = "${var.stopfunction}"
  role          = aws_iam_role.iam_for_lambda.arn
  handler       = "ec2_stop.lambda_handler"

  # The filebase64sha256() function is available in Terraform 0.11.12 and later
  # For Terraform 0.11.11 and earlier, use the base64sha256() function and the file() function:
  # source_code_hash = "${base64sha256(file("lambda_function_payload.zip"))}"
  source_code_hash = "${data.archive_file.zip.output_base64sha256}"

  runtime = "python3.6"

  environment {
    variables = {
      foo = "bar"
    }
  }
}


resource "aws_cloudwatch_event_rule" "every_min" {
  name        = "stop-instance"
  description = "stop running vm"
  schedule_expression = "${var.stopjobtime}"
}

resource "aws_cloudwatch_event_target" "checkmin" {
  rule      = "${aws_cloudwatch_event_rule.every_min.name}"
  target_id = "lambda"
  arn       = "${aws_lambda_function.test_lambda.arn}"
}

resource "aws_lambda_permission" "allow_cloudwatch1" {
  statement_id  = "AllowExecutionFromCloudWatch1"
  action        = "lambda:InvokeFunction"
  function_name = "ec2-stop_lambda"
  principal     = "events.amazonaws.com"
  source_arn    = "${aws_cloudwatch_event_rule.every_min.arn}"
}

#####################ec2 start lambda function #######################

data "archive_file" "zip2" {
  type = "zip"
  source_file = "${var.file2}"
  output_path = "${var.file2}.zip"
}
resource "aws_lambda_function" "ec2-start_lambda" {
  filename      = "${data.archive_file.zip2.output_path}"
  function_name = "${var.startfunction}"
  role          = aws_iam_role.iam_for_lambda.arn
  handler       = "ec2_start.lambda_handler"
  # The filebase64sha256() function is available in Terraform 0.11.12 and later
  # For Terraform 0.11.11 and earlier, use the base64sha256() function and the file() function:
  # source_code_hash = "${base64sha256(file("lambda_function_payload.zip"))}"
  source_code_hash = "${data.archive_file.zip.output_base64sha256}"
  runtime = "python3.6"
  environment {
    variables = {
      foo = "ec2-start"
    }
  }
}


resource "aws_cloudwatch_event_rule" "every_one_minute" {
  name                = "start-instance"
  description         = "Fires every one minutes"
  schedule_expression = "${var.startjobtime}"
}


resource "aws_cloudwatch_event_target" "check_foo_every_one_minute" {
  rule      = "${aws_cloudwatch_event_rule.every_one_minute.name}"
  target_id = "lambda"
  arn       = "${aws_lambda_function.ec2-start_lambda.arn}"
}

resource "aws_lambda_permission" "allow_cloudwatch_to_call_check_foo" {
  statement_id  = "AllowExecutionFromCloudWatch"
  action        = "lambda:InvokeFunction"
  function_name = "ec2-start_lambda"
  principal     = "events.amazonaws.com"
  source_arn    = "${aws_cloudwatch_event_rule.every_one_minute.arn}"
}
