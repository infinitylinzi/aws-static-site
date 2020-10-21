
resource "random_pet" "suffix" {
}

resource "aws_wafv2_ip_set" "iw_vpn" {
  provider = aws.us_east_1
  name               = "iw-vpn-${random_pet.suffix.id}"
  scope              = "CLOUDFRONT"
  ip_address_version = "IPV4"
  addresses          = ["52.51.7.138/32"]

  tags = {
    Owner = "Jonathan Cowling"
    Group = "Academy 2020"
    Creator = "Terraform"
  }
}

resource "aws_wafv2_regex_pattern_set" "error" {
  provider = aws.us_east_1
  name        = "error-pages-${random_pet.suffix.id}"
  scope       = "CLOUDFRONT"

  regular_expression {
    regex_string = "/error.*\\.html"
  }

  regular_expression {
    regex_string = "/assets/error-.*"
  }

  tags = {
    Owner = "Jonathan Cowling"
    Group = "Academy 2020"
    Creator = "Terraform"
  }
}

resource "aws_wafv2_web_acl" "acl" {
  provider = aws.us_east_1
  name = "cloudfront-acl-${random_pet.suffix.id}"
  scope = "CLOUDFRONT"

  default_action {
    block {}
  }

  rule {
    name = "allow-error-content"
    priority = 0

    action {
      allow {}
    }

    statement {
      regex_pattern_set_reference_statement {
        arn = aws_wafv2_regex_pattern_set.error.arn
        field_to_match {
          uri_path {}
        }
        text_transformation {
          priority = 0
          type = "URL_DECODE"
        }
      }
    }

    visibility_config {
      cloudwatch_metrics_enabled = false
      metric_name                = "allow-error-content"
      sampled_requests_enabled   = false
    }
  }

  rule {
    name = "allow-from-vpn"
    priority = 1

    action {
      allow {}
    }

    statement {
      ip_set_reference_statement {
        arn = aws_wafv2_ip_set.iw_vpn.arn
      }
    }

    visibility_config {
      cloudwatch_metrics_enabled = false
      metric_name                = "allow-from-vpn"
      sampled_requests_enabled   = false
    }
  }

  tags = {
    Owner = "Jonathan Cowling"
    Group = "Academy 2020"
    Creator = "Terraform"
  }

  visibility_config {
    cloudwatch_metrics_enabled = false
    metric_name                = "acl"
    sampled_requests_enabled   = false
  }
}
