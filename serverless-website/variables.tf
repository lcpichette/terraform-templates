variable "website_domain" {
  description = "e.g. mydomain.com OR www.mydomain.com"
  type        = string
}

variable "price_class" {
  description    = "PriceClass_{x}; {x}=[100,200,All]. https://docs.aws.amazon.com/AmazonCloudFront/latest/DeveloperGuide/PriceClass.html"
  type           = string
  default        = "PriceClass_100"
}

variable "environment" {
  description    = "e.g. development, staging, production"
  type           = string
}

