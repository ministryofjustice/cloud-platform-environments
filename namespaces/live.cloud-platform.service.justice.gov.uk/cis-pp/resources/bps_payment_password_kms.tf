resource "aws_kms_key" "bps_payment_password" {
  description             = "Encrypt civil payment archive passwords"
  enable_key_rotation     = true
  deletion_window_in_days = 30

  lifecycle {
    prevent_destroy = true
  }

  tags = merge(var.tags, {
    Name = "${var.namespace}-bps-payment-password"
  })
}

resource "aws_kms_alias" "bps_payment_password" {
  name          = "alias/${var.namespace}-bps-payment-password"
  target_key_id = aws_kms_key.bps_payment_password.key_id
}
