output "supanova_infra_access_key_id" {
  value = aws_iam_access_key.supanova_infra_dev_user_key.id
}

output "supanova_infra_secret_access_key" {
  value     = aws_iam_access_key.supanova_infra_dev_user_key.secret
  sensitive = true
}
