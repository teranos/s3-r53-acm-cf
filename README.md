# static-site

Reusable OpenTofu module: private S3 bucket + CloudFront (OAC) + ACM
cert + Route 53 records. The site bucket stays private; only the
distribution can read it.

## Inputs

| Name                | Type           | Required | Default      |
|---------------------|----------------|----------|--------------|
| `domains`           | `list(string)` | yes      | —            |
| `route53_zone_name` | `string`       | yes      | —            |
| `bucket_name`       | `string`       | no       | `domains[0]` |
| `root_object`       | `string`       | no       | `index.html` |
| `price_class`       | `string`       | no       | `PriceClass_100` |
| `tags`              | `map(string)`  | no       | `{}`         |

`domains[0]` is the primary; the rest become both subject-alternative
names on the cert and additional aliases on the distribution. The
Route 53 zone identified by `route53_zone_name` must already exist
and own DNS for every entry in `domains`.

## Provider requirements

The caller must configure an `aws.us_east_1` provider alias (ACM
hard-requires CloudFront certs in us-east-1) and pass both providers
to the module.

## Usage

```hcl
provider "aws" {
  region  = "eu-central-1"
  profile = "sbvh"
}

provider "aws" {
  alias   = "us_east_1"
  region  = "us-east-1"
  profile = "sbvh"
}

module "site" {
  source = "../../modules/static-site"

  providers = {
    aws           = aws
    aws.us_east_1 = aws.us_east_1
  }

  domains           = ["example.com", "www.example.com"]
  route53_zone_name = "example.com"
  root_object       = "index.html"
}
```

## Outputs

| Name                       | Description |
|----------------------------|-------------|
| `bucket_name`              | Bucket id; sync deploys here. |
| `bucket_arn`               | For downstream IAM. |
| `distribution_id`          | For `aws cloudfront create-invalidation`. |
| `distribution_arn`         | For IAM resource-level permissions. |
| `distribution_domain_name` | The `d1234.cloudfront.net` hostname. |
| `urls`                     | Public HTTPS URLs. |

## Deploying content

The module provisions infrastructure only. Upload site contents
with:

```sh
aws s3 sync ./dist/ s3://$(tofu output -raw bucket_name)/ --delete
aws cloudfront create-invalidation \
  --distribution-id $(tofu output -raw distribution_id) \
  --paths '/*'
```

## What's intentionally not here

- No GitHub Actions OIDC role / deploy IAM. That belongs in the
  caller, scoped to the caller's repo.
- No bucket versioning, lifecycle, or replication.
- No custom cache behaviors or path-based routing.
- No WAF.

Add any of these in the caller if a project needs them.
