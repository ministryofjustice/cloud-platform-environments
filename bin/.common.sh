# shellcheck shell=sh

log() {
  _fg=''
  [ "${1}" = "red" ] && _fg='\033[0;31m'
  [ "${1}" = "blue" ] && _fg='\033[0;34m'
  [ "${1}" = "green" ] && _fg='\033[0;32m'
  shift
  # shellcheck disable=SC2145
  echo -e "${_fg}>>> ${@}\033[0m"
}

_checkenv(){
  missing=""
  for v in \
      PIPELINE_CLUSTER \
      PIPELINE_STATE_BUCKET \
      PIPELINE_STATE_KEY_PREFIX \
      PIPELINE_CLUSTER_STATE_BUCKET \
      PIPELINE_CLUSTER_STATE_KEY_PREFIX; do
    fv=""
    eval fv="\${$v+xyz}"
    if [ -z "${fv}" ]; then
      missing="${missing}\n\t${v}"
    fi
  done
  if [ ! -z "${missing}" ]; then
    echo -e "missing environment variables:${missing}"
    exit 1
  fi
}
