terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 4.16"
    }
  }

  required_version = ">= 1.2.0"
}

provider "aws" {
  region  = var.region
}

/* NOTE:
 * Since this will be for clients, I'll know what
 * kind of data they'll be wanting to add/change.
 * This means it can be structured OR unstructured.
*/

/* NOTE:
 * Creating and Destroying AWS Infrastructure via Terraform
 * - Done locally
 * - Always stored in GitHub
*/

//! EACH CLIENT HAS THEIR OWN CMS SITE

/*
 * !Organizations Account
 * - A sub-account under the organization for consolidated billing
 * - We get the bill, so they gotta pay their portion monthly
 * - We can offer a brackets/plans, paying $x/mo
 * 
 * - 1 new account per-client
 *
 * Resource: aws_organizations_account
*/

resource "aws_organizations_account" "account" {
  name  = var.company_name
  email = var.account_manager_email
 
  iam_user_access_to_billing = "DENY"
  parent_id = "r-30fx"
}

/*
 * !API Gateway
 * - Accepts HTTP requests and returns data accordingly
 * 
 * - 1 per client
 *
 * Resource: aws_apigatewayv2_api
 *   - protocol: HTTP
 *
 * Routes (client):
 *   - GET, POST, DELETE /<resource_name>
 *     - GET, POST, DELETE /<resource_name>/:id
 *   - GET /usage
 *   - GET /usage/:client_id
*/

resource "aws_api_gateway_rest_api" "client_api" {
  name = "api.${var.company_name}"
}

# -- 
# CMS-RESOURCE: PAGES
# --

resource "aws_api_gateway_resource" "pages_resource" {
  rest_api_id = aws_api_gateway_rest_api.client_api.id
  parent_id = aws_api_gateway_rest_api.client_api.root_resource_id
  path_part = "pages"
}

resource "aws_api_gateway_method" "pages_method" {
  rest_api_id = aws_api_gateway_rest_api.client_api.id
  resouce_id = aws_api_gateway_resource.pages_resource.id
  http_method = "GET"
  authorization = "NONE"
}

resource "aws_api_gateway_integration" "pages_integration" {
  rest_api_id          = aws_api_gateway_rest_api.client_api.id
  resource_id          = aws_api_gateway_resource.pages_resource.id
  http_method          = aws_api_gateway_method.pages_method.http_method
  
  # Lambda Proxy Integration
  type                 = "AWS_PROXY"
  /* Lambda Proxy will work the same. Simpler than plain Lambda.
   * Just Lambda would allow transformations at the API Gateway level.
   * Lambda Proxy send request data directly to Lambda instead.
   * This also means the Lambda sets the status code in Lambda Proxy.
  */
  
  timeout_milliseconds = 29000
  uri                  = aws_lambda_function.getPages_fn.invoke_arn 
}

resource "aws_lambda_permission" "apigw_lambda" {
  statement_id  = "AllowExecutionFromAPIGateway"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.getPages_fn.function_name
  principal     = "apigateway.amazonaws.com"

  # More: http://docs.aws.amazon.com/apigateway/latest/developerguide/api-gateway-control-access-using-iam-policies-to-invoke-api.html
  source_arn = "arn:aws:execute-api:${var.region}:${aws_organizations_account.account.id}:${aws_api_gateway_rest_api.client_api.id}/*/${aws_api_gateway_method.method.http_method}${aws_api_gateway_resource.resource.path}"
}

resource "aws_lambda_function" "getPages_fn" {
  filename      = "lambda_getPages.zip"
  function_name = "getPages"
  role          = aws_iam_role.lambda_role.arn
  handler       = "lambda_getPages.lambda_handler"
  runtime       = "python3.7"

  source_code_hash = filebase64sha256("lambda_getPages.zip")
}

# --

resource "aws_iam_role" "lambda_role" {
  name = "myrole"

  assume_role_policy = <<POLICY
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
POLICY
}

/*
 * !DynamoDB
 * - Stores the clients entries
 *   - indirectly stores media; links to S3 object
 * - Stores authentication for CMS access
 * - Stores how much clients are using the CMS (reads & writes to db)
 *   - Updated once every 24 hours via cron job
 * 
 * - 1 per client
 *
 * Resource: aws_dynamodb_table
 *   - billing_mode: PAY_PER_REQUEST
*/

/* 
 * !EC2
 * - Cron Jobs to query client DBs to see their utilization
 * - Spot instance that runs for 60 minutes once every 24 hours
 *
 * - 1 for billing & analytics
 * 
 * Resource: aws_spot_instance_request
*/

/*
 * !S3
 * - Media storage for clients entries
 * - Static Hosting
 * 
 * - 2 per client
 *   - 1 for CMS media entries
 *   - 1 for hosting
*/

/*
 * !Route53
 * - Domain itself (initially non-used directly)
 * - Sub-domains for each client's CMS
*/
