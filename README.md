# static-site

Reusable OpenTofu module: private S3 bucket + CloudFront (OAC) + ACM
cert + Route 53 records. The site bucket stays private; only the
distribution can read it.

Inputs: [`variables.tf`](./variables.tf). Outputs: [`outputs.tf`](./outputs.tf).
