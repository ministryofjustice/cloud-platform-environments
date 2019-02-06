# Running the pipeline locally

Clone the `cloud-platform-environment` repository locally. If you typically have a dirty working environment and don't want to clean it up, it might be safer and easier to just clone a fresh copy of the repository.

From the root of that directory, you should then be able to:

```
docker run -it \
  -v $PWD:/cloud-platform-environments-repo \
  -w /cloud-platform-environments-repo \
  -eTF_PLUGIN_CACHE_DIR=/tmp/terraform-plugin-cache \
  -eKUBECONFIG=/tmp/kubeconfig \
  -eAWS_ACCESS_KEY_ID=$(kubectl -nconcourse-main get secret aws -o json | jq -r '.data["access-key-id"] | @base64d') \
  -eAWS_SECRET_ACCESS_KEY=$(kubectl -nconcourse-main get secret aws -o json | jq -r '.data["secret-access-key"] | @base64d') \
  environments-pipeline \
  /bin/sh -c '\
    mkdir -p "${TF_PLUGIN_CACHE_DIR}" \
    && aws s3 cp s3://cloud-platform-concourse-build-environments/kubeconfig /tmp/kubeconfig \
    && ./bin/apply \
    && sh'
```
