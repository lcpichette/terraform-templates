/* 
 * Route53
*/

resource "aws_route53_zone" "primary" {
  name = aws_cloudfront_distribution.s3_distribution.domain_name
}

resource "aws_route53_zone" "dev" {
  name = "dev.${var.website_domain}"
  
  tags = {
    Environment = "development"
  }
}

