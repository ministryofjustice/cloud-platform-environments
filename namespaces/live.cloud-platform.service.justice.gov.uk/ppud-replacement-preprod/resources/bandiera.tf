data "kubernetes_secret" "ppud_replacement_dev_bandiera_secret" {
  metadata {
    name      = "bandiera-basic-auth"
    namespace = "ppud-replacement-dev"
  }
}

resource "kubernetes_secret" "ppud_replacement_bandiera_basic_auth" {
  metadata {
    name      = "bandiera-basic-auth"
    namespace = var.namespace
  }

  data = {
    username = data.kubernetes_secret.ppud_replacement_dev_bandiera_secret.data.username
    password = data.kubernetes_secret.ppud_replacement_dev_bandiera_secret.data.password
  }
}
