
data "archive_file" "lambda_zip_file" {
  type = "zip"
  source_file = "${path.module}/src/index.js"
  output_path = "${path.module}/lambda.zip"
}

# Role to execute lambda
resource "aws_iam_role" "sqs_lambda_demo_functionrole" {
  name               = "sqs_lambda_demo_functionrole"
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

# CloudWatch Log group to store Lambda logs
resource "aws_cloudwatch_log_group" "sqs_lambda_demo_loggroup" {
  name = "/aws/lambda/${aws_lambda_function.sqs_lambda_demo_function.function_name}"
  retention_in_days = 365
}

# Custom policy to read SQS queue and write to CloudWatch Logs with least privileges
resource "aws_iam_policy" "sqs_lambda_demo_lambdapolicy" {
  name        = "sqs-lambda-demo-lambdapolicy"
  path        = "/"
  description = "Policy for sqs to lambda demo"
  policy = <<EOF
{
  "Version" : "2012-10-17",
  "Statement" : [
    {
      "Effect": "Allow",
      "Action": [
        "sqs:ReceiveMessage",
        "sqs:DeleteMessage",
        "sqs:GetQueueAttributes"
      ],
      "Resource": "${aws_sqs_queue.MySQSqueue.arn}"
    },
     {
                "Effect": "Allow",
                "Action": [
                    "dynamodb:GetItem",
                    "dynamodb:PutItem",
                    "dynamodb:UpdateItem"
                ],
                "Resource": "arn:aws:dynamodb:*:*:table/${var.dynamodb_table}"
            },
    {
      "Effect": "Allow",
      "Action": [
          "logs:CreateLogStream",
          "logs:PutLogEvents"
      ],
      "Resource": "arn:aws:logs:${data.aws_region.current.name}:${data.aws_caller_identity.current.account_id}:log-group:/aws/lambda/${aws_lambda_function.sqs_lambda_demo_function.function_name}:*:*"
    }
  ]
}
EOF
}

resource "aws_iam_role_policy_attachment" "lambda_policy_attachment" {
  role = aws_iam_role.sqs_lambda_demo_functionrole.name
  policy_arn = aws_iam_policy.sqs_lambda_demo_lambdapolicy.arn
}

resource "aws_lambda_function" "sqs_lambda_demo_function" {
  function_name = "sqs-lambda-demo-${data.aws_caller_identity.current.account_id}"
  filename = data.archive_file.lambda_zip_file.output_path
  source_code_hash = filebase64sha256(data.archive_file.lambda_zip_file.output_path)
  role = aws_iam_role.sqs_lambda_demo_functionrole.arn
  handler = "index.handler"
  runtime = "nodejs16.x"
   environment {
      variables = {
        DDB_TABLE = var.dynamodb_table
      }
    }
}

resource "aws_lambda_event_source_mapping" "sqs_lambda_demo_sourcemapping" {
  event_source_arn = aws_sqs_queue.MySQSqueue.arn
  function_name = aws_lambda_function.sqs_lambda_demo_function.function_name
}


output "lambda_function_name" {
  value = aws_lambda_function.sqs_lambda_demo_function.function_name
}

output "cloudwatch_log_group" {
  value = aws_cloudwatch_log_group.sqs_lambda_demo_loggroup.name
}