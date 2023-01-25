#!/bin/bash

set -eox

ca_certificate_subject="/C=GB/ST=London/L=London/O=Ministry of Justice/CN=development.integration-api.hmpps.service.justice.gov.uk"
client_certificate_subject="/C=GB/ST=London/L=London/O=Some Client/CN=some.client.org"

generate_certificate_authority() {
  openssl genrsa -out truststore.key 4096 -subj "$ca_certificate_subject"
  openssl req -new -x509 -days 3650 -key truststore.key -out truststore.pem -subj "$ca_certificate_subject"
}

generate_client() {
  openssl genrsa -out my_client.key 2048
  openssl req -new -key my_client.key -out my_client.csr -subj "$client_certificate_subject"
  openssl x509 -req -in my_client.csr -CA truststore.pem -CAkey truststore.key -set_serial 01 -out my_client.pem -days 365 -sha256
}

main() {
  generate_certificate_authority
  generate_client
}

main
