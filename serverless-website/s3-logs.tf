/* 
 * S3 - Logging Bucket
*/
resource "aws_s3_bucket" "logging_bucket" {
  bucket    = "logs.${var.website_domain}"
}
