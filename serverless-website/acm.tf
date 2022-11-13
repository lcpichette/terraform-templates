/*
 * Amazon Certificate Manager (ACM)
*/

resource "aws_acm_certificate" "cert" {
  domain_name = var.website_domain
  validation_method = "DNS"
  
  lifecycle {
    create_before_destroy = true
  }
}

