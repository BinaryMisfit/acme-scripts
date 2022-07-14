#!/usr/bin/env bash
if [ -d "$HOME/acme.sh" ]; then
  exit
fi

mkdir -p /tmp/acme.sh
mkdir -p "$HOME/.acme.sh"
git clone -qq https://github.com/acmesh-official/acme.sh.git /tmp/acme.sh
pushd /tmp/acme.sh >/dev/null || return
"/tmp/acme.sh/acme.sh" --install \
  --home "$HOME/.acme.sh" \
  --config-home "$LE_CONFIG_HOME" \
  --cert-home "$LE_CERT_HOME" \
  --accountemail "$LE_EMAIL" \
  "$ACME_SH_ARGS"
popd >/dev/null || return
rm -rf /tmp/acme.sh
pushd "$HOME/.acme.sh" >/dev/null || return
/bin/bash -c "$HOME/.acme.sh/acme.sh --upgrade --auto-upgrade"
popd >/dev/null || return
