output "bucket_name" {
  description = "S3 bucket holding the site contents. `aws s3 sync` deploys here."
  value       = aws_s3_bucket.site.id
}

output "bucket_arn" {
  description = "Bucket ARN — useful for downstream IAM policies (e.g. a CI deploy role)."
  value       = aws_s3_bucket.site.arn
}

output "distribution_id" {
  description = "CloudFront distribution ID. Use for `aws cloudfront create-invalidation`."
  value       = aws_cloudfront_distribution.site.id
}

output "distribution_arn" {
  description = "Distribution ARN — for the bucket policy and for resource-level IAM permissions on `cloudfront:CreateInvalidation`."
  value       = aws_cloudfront_distribution.site.arn
}

output "distribution_domain_name" {
  description = "The d1234.cloudfront.net hostname. Aliases (var.domains) are the user-facing names."
  value       = aws_cloudfront_distribution.site.domain_name
}

output "urls" {
  description = "Public HTTPS URLs the site is served at."
  value       = [for d in var.domains : "https://${d}/"]
}
