variable "domains" {
  description = "Fully-qualified domain names to serve. domains[0] is the primary; the rest become subject_alternative_names on the cert and additional aliases on the distribution. All must be inside the Route 53 zone identified by `route53_zone_name`."
  type        = list(string)

  validation {
    condition     = length(var.domains) >= 1
    error_message = "Provide at least one domain."
  }
}

variable "route53_zone_name" {
  description = "Apex domain of the Route 53 hosted zone that owns DNS for all of `domains`. Looked up via data source — the zone must already exist."
  type        = string
}

variable "bucket_name" {
  description = "S3 bucket name. Global namespace. Defaults to domains[0]."
  type        = string
  default     = null
}

variable "root_object" {
  description = "Default object CloudFront serves for `/`."
  type        = string
  default     = "index.html"
}

variable "price_class" {
  description = "CloudFront price class. PriceClass_100 (NA+EU) is the cheapest."
  type        = string
  default     = "PriceClass_100"
}

variable "tags" {
  description = "Tags applied to all resources (in addition to provider default_tags)."
  type        = map(string)
  default     = {}
}

variable "response_headers_policy_id" {
  description = "Optional CloudFront response-headers policy attached to the default cache behavior. Use to add HSTS, CSP, X-Frame-Options, etc. Caller defines the policy and passes the id."
  type        = string
  default     = null
}

variable "viewer_request_function_arn" {
  description = "Optional CloudFront Function ARN attached to the default cache behavior on viewer-request. Use for URI rewrites (e.g. per-prefix SPA fallback) or KVS-backed lookups. Caller creates the function and passes the ARN."
  type        = string
  default     = null
}

variable "proxied_paths" {
  description = "Path patterns served from a host other than the bucket, so they are same-origin with the site. Each entry names the pattern and the origin host. Uncached: an origin behind one of these answers per request."
  type = list(object({
    pattern = string
    host    = string
  }))
  default = []
}

variable "custom_error_responses" {
  description = "Optional custom error responses on the distribution (e.g. map 403/404 to /404.html). Each entry mirrors the CloudFront resource block; nullable fields are skipped when omitted."
  type = list(object({
    error_code            = number
    response_code         = optional(number)
    response_page_path    = optional(string)
    error_caching_min_ttl = optional(number)
  }))
  default = []
}
