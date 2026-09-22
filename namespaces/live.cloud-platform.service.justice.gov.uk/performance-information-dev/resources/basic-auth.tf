# Username and password for the demo website's nginx ingress http basic
# authentication
resource "kubernetes_secret" "basic-auth" {
  metadata {
    name      = "basic-auth"
    namespace = var.namespace
  }

  # nginx ingress basic auth expects a single "auth" key in htpasswd format:
  # "<username>:<bcrypt-hashed-password>"
  data = {
    auth = "${var.basic-auth-username}:${bcrypt(var.basic-auth-password)}"
  }

  lifecycle {
    # bcrypt() generates a new salt on every run, which would otherwise force
    # the secret to be recreated on each apply.
    ignore_changes = [data]
  }
}
