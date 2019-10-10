# shellcheck shell=bash

log() {
  _fg=''
  [ "${1}" = "red" ] && _fg='\033[0;31m'
  [ "${1}" = "blue" ] && _fg='\033[0;34m'
  [ "${1}" = "green" ] && _fg='\033[0;32m'
  shift
  # shellcheck disable=SC2145
  echo -e "${_fg}>>> ${@}\033[0m"
}
