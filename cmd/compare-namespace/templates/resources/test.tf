module "module-test" {
  namespace = "test-namespace"
}

module "module-test" {

  tags = {
    "test" = "test"
  }
}

resource "resource-test" "test" {
  metadata {
    name      = "test"
    namespace = "test-namespace"
  }
}

resource "resource-test" "test" {
  metadata {
    name      = "test-with-variable"
    namespace = var.namespace
  }
}

resource "resource-test" "test" {
  metadata {

  }
  tags = {
    "test" = "test"
  }
}