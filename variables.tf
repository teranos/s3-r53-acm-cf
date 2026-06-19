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
