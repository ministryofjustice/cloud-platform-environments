defaultBackend:
  enabled: true

  name: default-backend
  image:
    repository: ministryofjustice/manage-a-workforce-custom-error-pages
    tag: "0.3"
    pullPolicy: IfNotPresent

  extraArgs: {}

  port: 8080