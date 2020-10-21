terraform {
  required_providers {
    aws = {
      version = "~> 3.0"
    }
  }
}

provider "aws" {
}

provider "aws" {
  alias = "us_east_1"
  region = "us-east-1"
}

resource "aws_cloudfront_origin_access_identity" "origin_access_identity" {
}

resource "aws_cloudfront_distribution" "s3_distribution" {
  origin {
    domain_name = aws_s3_bucket.static.bucket_regional_domain_name
    origin_id   = "s3"

    s3_origin_config {
      origin_access_identity = aws_cloudfront_origin_access_identity.origin_access_identity.cloudfront_access_identity_path
    }
  }

  enabled             = true
  is_ipv6_enabled     = true
  default_root_object = "index.html"

  aliases = [
    // custom domain name(s)
  ]

  default_cache_behavior {
    allowed_methods  = ["DELETE", "GET", "HEAD", "OPTIONS", "PATCH", "POST", "PUT"]
    cached_methods   = ["GET", "HEAD"]
    target_origin_id = "s3"

    forwarded_values {
      query_string = false

      cookies {
        forward = "none"
      }
    }

    viewer_protocol_policy = "redirect-to-https"
    min_ttl                = 0
    default_ttl            = 3600
    max_ttl                = 86400
  }
  
  restrictions {
    geo_restriction {
      restriction_type = "none"
    }
  }

  web_acl_id = aws_wafv2_web_acl.acl.arn

  custom_error_response {
    error_code = 404
    response_code = 404
    response_page_path = "/error.html"
  }

  custom_error_response {
    error_code = 403
    response_code = 404
    response_page_path = "/error.html"
  }

  price_class = "PriceClass_100"

  tags = {
    Owner = "Jonathan Cowling"
    Group = "Academy 2020"
    Creator = "Terraform"
  }

  viewer_certificate {
    cloudfront_default_certificate = true
  }
}
