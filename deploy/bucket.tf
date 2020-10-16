data "aws_iam_policy_document" "bucket" {
  version = "2012-10-17"
  statement {
    principals  {
      type = "AWS"
      identifiers = [aws_cloudfront_origin_access_identity.origin_access_identity.iam_arn]
    }
    actions   = ["s3:GetObject"]
    resources = ["${aws_s3_bucket.static.arn}/*"]
  }
}

resource "aws_s3_bucket_policy" "static_policy" {
  bucket = aws_s3_bucket.static.id
  policy = data.aws_iam_policy_document.bucket.json
}

resource "aws_s3_bucket" "static" {
  bucket_prefix = "static-"
  
  tags = {
    Owner = "Jonathan Cowling"
    Group = "Academy 2020"
    Creator = "Terraform"
  }

  // using website is an alternative to using cloudfront,
  // but requires the parameter acl = "public-read"
  // website {
  //   index_document = "index.html"
  //   error_document = "error.html"
  // }
}

resource "aws_s3_bucket_object" "object" {
  bucket = aws_s3_bucket.static.bucket
  for_each = fileset("${path.root}/../static", "**.html")
  key    = each.key
  source = "${path.root}/../static/${each.key}"
  content_type = "text/html"
  etag = filemd5("${path.root}/../static/${each.key}")
}