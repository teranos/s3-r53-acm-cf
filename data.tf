data "aws_route53_zone" "this" {
  name         = "${var.route53_zone_name}."
  private_zone = false
}

# AWS-managed CloudFront cache policy. IDs are stable but names are
# documented and grep-able; using the data source is the pattern AWS
# recommends.
data "aws_cloudfront_cache_policy" "caching_optimized" {
  name = "Managed-CachingOptimized"
}

locals {
  bucket_name      = coalesce(var.bucket_name, var.domains[0])
  primary_domain   = var.domains[0]
  alternate_names  = slice(var.domains, 1, length(var.domains))
  resource_id_base = replace(local.bucket_name, ".", "-")
}
