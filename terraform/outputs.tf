output "evidence_bucket_name" {
  description = "S3 bucket that stores CloudTrail evidence."
  value       = aws_s3_bucket.evidence.id
}

output "access_log_bucket_name" {
  description = "S3 bucket that stores access logs for the evidence bucket."
  value       = aws_s3_bucket.access_logs.id
}

output "cloudtrail_name" {
  description = "Name of the multi-Region CloudTrail trail."
  value       = aws_cloudtrail.audit.name
}

output "cloudwatch_log_group_name" {
  description = "CloudWatch Logs destination for CloudTrail events."
  value       = aws_cloudwatch_log_group.cloudtrail.name
}

output "kms_key_arn" {
  description = "ARN of the customer-managed key protecting audit evidence."
  value       = aws_kms_key.audit.arn
}
