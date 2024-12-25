resource "aws_ses_email_identity" "emails" {
  for_each = toset(var.email_addresses)
  email    = each.value
}
