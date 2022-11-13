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
  region  = "us-west-2"
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
 * Organizations Account
 * - A sub-account under the organization for consolidated billing
 * - We get the bill, so they gotta pay their portion monthly
 * - We can offer a brackets/plans, paying $x/mo
 * 
 * - 1 new account per-client
 *
 * Resource: aws_organizations_account
*/

/*
 * API Gateway
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

/*
 * DynamoDB
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
 * EC2
 * - Cron Jobs to query client DBs to see their utilization
 * - Spot instance that runs for 60 minutes once every 24 hours
 *
 * - 1 for billing & analytics
 * 
 * Resource: aws_spot_instance_request
*/

/*
 * S3
 * - Media storage for clients entries
 * - Static Hosting
 * 
 * - 2 per client
 *   - 1 for CMS media entries
 *   - 1 for hosting
*/

/*
 * Route53
 * - Domain itself (initially non-used directly)
 * - Sub-domains for each client's CMS
*/
