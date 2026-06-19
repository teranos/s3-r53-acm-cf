# static-site

Reusable OpenTofu module: private S3 bucket + CloudFront (OAC) + ACM
cert + Route 53 records. The site bucket stays private; only the
distribution can read it.

Inputs: [`variables.tf`](./variables.tf). Outputs: [`outputs.tf`](./outputs.tf).

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
  source = "git::https://github.com/teranos/s3-r53-acm-cf.git?ref=v0.1.1"

  providers = {
    aws           = aws
    aws.us_east_1 = aws.us_east_1
  }

  domains           = ["example.com", "www.example.com"]
  route53_zone_name = "example.com"
  root_object       = "index.html"
}
```

## Deploying content

The module provisions infrastructure only. Upload site contents
with:

```sh
aws s3 sync ./dist/ s3://$(tofu output -raw bucket_name)/ --delete
aws cloudfront create-invalidation \
  --distribution-id $(tofu output -raw distribution_id) \
  --paths '/*'
```
