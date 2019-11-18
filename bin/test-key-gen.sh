#!/bin/bash
set -e

ns="concourse-webops"
ctx="z"
code="../my-app-dir/"

# Create a temporary keychain
homedir="$(mktemp -d "${TMPDIR:-/tmp}/simplegpg-XXXXXX")"
cleanup() {
    rm -rf -- "$homedir"
}
trap cleanup INT TERM EXIT

generate() {
    if [ -z "$pubkey" -o -z "$seckey" ]; then
        fatal "must specify pubkey and seckey"
    fi
    if [ "${pubkey##*.}" != asc -o \
         "${seckey##*.}" != pgp -o \
         "${pubkey%.*}" != "${seckey%.*}" ]; then
        fatal "please use naming scheme of keyname.asc and keyname.pgp"
    fi
    if [ -e "$pubkey" ]; then
        fatal "would clobber $pubkey"
    fi
    if [ -e "$seckey" ]; then
        fatal "would clobber $seckey"
    fi
    if [ -z "$comment" ]; then
        # This is a GnuPG limitation, not an OpenPGP limitation
        fatal "comment must not be empty"
    fi

    # The passphrase must be managed by the script because otherwise
    # GnuPG will ask for it more than necessary. It's too bad that
    # gpg-agent can't pick up on the secret key at the same time it's
    # generated. Also, the GnuPG --passphrase-repeat option is broken.
    passphrase=
    if [ $passwd = yes ]; then
        passphrase=$(readpw "passphrase")
        if [ -z "$passphrase" ]; then
            fatal "please provide a passphrase"
        fi
        confirm=$(readpw "passphrase (confirm)")
        if [ "$passphrase" != "$confirm" ]; then
            fatal "passphases don't match"
        fi
    fi

    gpg --quiet --homedir "$homedir" --batch --lock-never \
        --passphrase-fd 0 \
        --quick-generate-key "$comment" rsa4096 encrypt never \
        2>/dev/null \
        <<EOF
$passphrase
EOF
    gpg --quiet --homedir "$homedir" --batch --lock-never \
        --pinentry-mode loopback \
        --passphrase-fd 0 \
        --armor \
        --comment "$comment" \
        --export-secret-keys \
        --output "$seckey" \
        <<EOF
$passphrase
EOF
    gpg --quiet --homedir "$homedir" --batch --lock-never \
        --armor \
        --comment "$comment" \
        --export \
        --output "$pubkey"
}

readpw() {
    # This function is expected to run in a subshell, i.e. $(...).
    stty -echo
    # Note: Don't rely on EXIT trap here since there's a bug in
    # OpenBSD's ksh such that it doesn't execute EXIT traps for
    # subshells. It's very easy to work around it, so just do so.
    trap 'stty echo; printf >/dev/tty "\n"' INT TERM
    printf >/dev/tty '%s: ' "$1"
    read -r passphrase
    printf >/dev/tty "\n"
    stty echo
    # Note: Always use a heredoc to write the passphrases so that it's
    # not used as an argument, even to a built-in.
    cat <<EOF
$passphrase
EOF
}

chmod 700 "$homedir"
pubkey="${homedir}/gitops.asc"
seckey="${homedir}/gitops.pgp"
comment="gitops-${ns}"
passwd=no

generate

pub=`cat "${pubkey}" | base64`
priv=`cat "${seckey}" | base64`

cat <<SEC | kubectl --context ${ctx} -n ${ns} apply -f -
apiVersion: v1
kind: Secret
metadata:
  name: git-crypt-key
  namespace: ${ns}
data:
  private: ${priv}
  public: ${pub}
SEC

ksec=`kubectl --context ${ctx} -n ${ns} get secret git-crypt-key -o json | jq -r '.data.public | @base64d'`

id=`echo "${ksec}" | gpg --import 2>&1 | grep "gitops" | awk -F' |:' '{print $4}'`

echo -e "you must now run in ${code} the command \n git-crypt add-gpg-user --trusted ${id}"
