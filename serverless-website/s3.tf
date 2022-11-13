/* 
 * S3 - Origin Bucket
*/

resource "aws_s3_bucket" "origin_bucket" {
  bucket = var.website_domain
}

resource "aws_s3_bucket_policy" "origin_bucket_public_read_policy" {
  bucket = aws_s3_bucket.origin_bucket.id
  policy = <<EOF
  {
    "Version": "2012-10-17",
    "Statement": [
      {
        "Effect": "Allow",
        "Principal": "*",
        "Action": [
          "s3:Get*",
          "s3:List*"
        ],
        "Resource": [
          "arn:aws:s3:::${var.website_domain}/*",
          "arn:aws:s3:::${var.website_domain}"
        ]
      }
    ]
  }
  EOF
}

resource "aws_s3_bucket_acl" "origin_bucket_acl" {
  bucket = aws_s3_bucket.origin_bucket.id
  
  acl    = "public-read"
}

resource "aws_s3_bucket_website_configuration" "origin_bucket_website_configuration" {
  bucket = aws_s3_bucket.origin_bucket.id
  
  index_document {
    suffix = "index.html"
  }
}
