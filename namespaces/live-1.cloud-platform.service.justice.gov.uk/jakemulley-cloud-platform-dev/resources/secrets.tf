# WordPress requires 8 salts, as below - we can randomly generate them using
# Terraform and add them as Kubernetes secrets.
locals {
  salts = toset([
    "WORDPRESS_AUTH_KEY",
    "WORDPRESS_SECURE_AUTH_KEY",
    "WORDPRESS_LOGGED_IN_KEY",
    "WORDPRESS_NONCE_KEY",
    "WORDPRESS_AUTH_SALT",
    "WORDPRESS_SECURE_AUTH_SALT",
    "WORDPRESS_LOGGED_IN_SALT",
    "WORDPRESS_NONCE_SALT",
  ])
}

resource "random_password" "salt" {
  for_each = local.salts

  length           = 16
  special          = true
  override_special = "_%@"
}

resource "kubernetes_secret" "salts" {
  metadata {
    name      = "wordpress-salts"
    namespace = var.namespace
  }

  data = {
    for item in local.salts : item => base64encode(random_password.salt[item].result)
  }
}
