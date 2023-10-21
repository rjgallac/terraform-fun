https://serverlessland.com/patterns/apigw-sqs-lambda-ddb

https://github.com/aws-samples/serverless-patterns/tree/main/apigw-sqs-lambda-ddb
https://github.com/aws-samples/serverless-patterns/blob/main/apigw-sqs-terraform/main.tf
https://github.com/aws-samples/serverless-patterns/blob/main/sqs-lambda-terraform-python/main.tf
https://github.com/aws-samples/serverless-patterns/tree/main/apigw-lambda-dynamodb-terraform

terraform init
terraform apply

command should be output on cmd line after apply


curl --location --request POST 'https://uuwyu1yyxj.execute-api.us-east-1.amazonaws.com/default/submit' --header 'Content-Type: application/json'  --data-raw '{"year":2023, "title": "Hello From ApiGateway!" }'