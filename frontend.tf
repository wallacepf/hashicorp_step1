locals {
  mime_types = jsondecode(file("${path.module}/data/mime.json"))
}

locals {
  s3_origin_id = "S3FrontEDply"
}

resource "random_string" "random" {
  length  = 8
  special = false
  upper   = false
  number  = true
}

module "frontend_s3_bucket" {
  source  = "terraform-aws-modules/s3-bucket/aws"
  version = "~>1.0"
  bucket  = "frontend-${random_string.random.id}"
  acl     = "public-read"

  website = {
    index_document = "index.html"
    error_document = "404.html"
  }

  tags = local.common_tags

  depends_on = [
    null_resource.setup_frontend
  ]

  force_destroy = true
}

resource "aws_s3_bucket_object" "copy_app" {
  for_each = fileset("/Users/wallacepf/Dev/Study/cdond-c3-projectstarter/frontend/dist", "**")

  bucket = module.frontend_s3_bucket.this_s3_bucket_id
  key    = each.value
  source = "/Users/wallacepf/Dev/Study/cdond-c3-projectstarter/frontend/dist/${each.value}"

  etag         = filemd5("/Users/wallacepf/Dev/Study/cdond-c3-projectstarter/frontend/dist/${each.value}")
  content_type = lookup(local.mime_types, regex("\\.[^.]+$", each.value), null)


  acl = "public-read"
}

# resource "aws_cloudfront_origin_access_identity" "origin_access_identity" {
#   comment = "Origin Access Identity for Serverless Static Website"
# }

# resource "aws_cloudfront_distribution" "frontend_distribution" {
#   origin {
#     domain_name = module.frontend_s3_bucket.this_s3_bucket_bucket_regional_domain_name
#     origin_id   = local.s3_origin_id
#     s3_origin_config {
#       origin_access_identity = aws_cloudfront_origin_access_identity.origin_access_identity.cloudfront_access_identity_path
#     }
#   }


#   enabled             = true
#   default_root_object = "index.html"

#   default_cache_behavior {
#     allowed_methods  = ["DELETE", "GET", "HEAD", "OPTIONS", "PATCH", "POST", "PUT"]
#     cached_methods   = ["GET", "HEAD"]
#     target_origin_id = local.s3_origin_id
#     forwarded_values {
#       query_string = false
#       cookies {
#         forward = "none"
#       }
#     }
#     viewer_protocol_policy = "redirect-to-https"
#   }

#   restrictions {
#     geo_restriction {
#       restriction_type = "whitelist"
#       locations        = ["US", "BR"]
#     }
#   }

#   viewer_certificate {
#     cloudfront_default_certificate = true
#   }

#   wait_for_deployment = false

#   tags = local.common_tags

# }
