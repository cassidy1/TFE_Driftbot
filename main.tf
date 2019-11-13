data "archive_file" "driftBot" {
  type        = "zip"
  source_dir  = "functions/"
  output_path = "functions/driftBot.zip"
}

provider "aws" {
  region = var.aws_region
}

resource "aws_lambda_function" "drift_lambda" {
  filename      = "functions/driftBot.zip"
  function_name = "Driftbot-${var.TFE_ORG}"
  role          = aws_iam_role.iam_for_lambda.arn
  handler       = "driftBot.DriftDetector"

  runtime = "python3.6"
  timeout = 30

  environment {
    variables = {
      TFE_TOKEN = var.TFE_TOKEN
      TFE_URL   = var.TFE_URL
      TFE_ORG   = var.TFE_ORG
    }
  }

  depends_on = [data.archive_file.driftBot]
}

resource "aws_iam_role" "iam_for_lambda" {
  name = "iam_for_lambda-${var.TFE_ORG}"

  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": "sts:AssumeRole",
      "Principal": {
        "Service": "lambda.amazonaws.com"
      },
      "Effect": "Allow",
      "Sid": ""
    }
  ]
}
EOF

}

resource "aws_cloudwatch_event_rule" "event_run" {
  name                = "TFE_DB-${var.TFE_ORG}"
  description         = "Automated runs in TFE to detect drift"
  schedule_expression = "rate(${var.check_time} %{ if var.check_time == 1 }minute%{ else }minutes%{ endif })"
}

resource "aws_cloudwatch_event_target" "daily_running_report" {
  rule      = aws_cloudwatch_event_rule.event_run.name
  target_id = aws_lambda_function.drift_lambda.function_name
  arn       = aws_lambda_function.drift_lambda.arn
}

resource "aws_lambda_permission" "allow_cloudwatch_instance_usage" {
  statement_id  = "AllowExecutionFromCloudWatch"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.drift_lambda.function_name
  principal     = "events.amazonaws.com"
  source_arn    = aws_cloudwatch_event_rule.event_run.arn
}