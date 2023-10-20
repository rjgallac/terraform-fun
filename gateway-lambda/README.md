zip ../example.zip index.js


aws s3api create-bucket --bucket=robs-serverless-example --region=us-east-1

aws s3 cp example.zip s3://robs-serverless-example/v1.0.0/example.zip

terraform init

terraform apply

aws lambda invoke --region=us-east-1 --function-name=ServerlessExample output.txt


terraform destroy