resource "aws_cloudfront_distribution" "site" {
  enabled             = true
  is_ipv6_enabled     = true
  comment             = local.bucket_name
  default_root_object = var.root_object
  price_class         = var.price_class
  http_version        = "http2and3"
  aliases             = var.domains
  tags                = var.tags

  origin {
    domain_name              = aws_s3_bucket.site.bucket_regional_domain_name
    origin_id                = "s3-${local.resource_id_base}"
    origin_access_control_id = aws_cloudfront_origin_access_control.site.id
  }

  dynamic "origin" {
    for_each = toset([for p in var.proxied_paths : p.host])
    content {
      domain_name = origin.value
      origin_id   = "proxy-${replace(origin.value, ".", "-")}"

      custom_origin_config {
        http_port              = 80
        https_port             = 443
        origin_protocol_policy = "https-only"
        origin_ssl_protocols   = ["TLSv1.2"]
      }
    }
  }

  dynamic "ordered_cache_behavior" {
    for_each = var.proxied_paths
    content {
      path_pattern           = ordered_cache_behavior.value.pattern
      target_origin_id       = "proxy-${replace(ordered_cache_behavior.value.host, ".", "-")}"
      viewer_protocol_policy = "redirect-to-https"

      allowed_methods = ["GET", "HEAD"]
      cached_methods  = ["GET", "HEAD"]

      cache_policy_id            = data.aws_cloudfront_cache_policy.caching_disabled.id
      origin_request_policy_id   = data.aws_cloudfront_origin_request_policy.all_viewer_except_host.id
      response_headers_policy_id = var.response_headers_policy_id

      compress = true
    }
  }

  default_cache_behavior {
    target_origin_id       = "s3-${local.resource_id_base}"
    viewer_protocol_policy = "redirect-to-https"

    allowed_methods = ["GET", "HEAD"]
    cached_methods  = ["GET", "HEAD"]

    cache_policy_id            = data.aws_cloudfront_cache_policy.caching_optimized.id
    response_headers_policy_id = var.response_headers_policy_id

    compress = true

    dynamic "function_association" {
      for_each = var.viewer_request_function_arn == null ? [] : [1]
      content {
        event_type   = "viewer-request"
        function_arn = var.viewer_request_function_arn
      }
    }
  }

  dynamic "custom_error_response" {
    for_each = var.custom_error_responses
    content {
      error_code            = custom_error_response.value.error_code
      response_code         = try(custom_error_response.value.response_code, null)
      response_page_path    = try(custom_error_response.value.response_page_path, null)
      error_caching_min_ttl = try(custom_error_response.value.error_caching_min_ttl, null)
    }
  }

  restrictions {
    geo_restriction {
      restriction_type = "none"
    }
  }

  viewer_certificate {
    acm_certificate_arn      = aws_acm_certificate_validation.site.certificate_arn
    ssl_support_method       = "sni-only"
    minimum_protocol_version = "TLSv1.2_2021"
  }
}
