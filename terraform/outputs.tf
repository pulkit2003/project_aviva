output "public_subnet_id" {
  value = data.aws_subnet.existing.id
}

output "internet_gateway_id" {
  value = data.aws_internet_gateway.igw.id
}

output "static_site_bucket_name" {
  value = aws_s3_bucket.static_site.bucket
}

output "website_url" {
  value       = aws_s3_bucket_website_configuration.website_config.website_endpoint
  description = "Public URL of the static website bucket"
}
