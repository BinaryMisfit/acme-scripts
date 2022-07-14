#!/usr/bin/env bash
if [ -f "$HOME/.acme.sh/account.conf" ]; then
  exit
fi

"$HOME/.acme.sh/acme.sh" --register-account \
  --home "$HOME/acme.sh" \
  --config-home "$LE_CONFIG_HOME" \
  --cert-home "$LE_CERT_HOME" \
  -m "$LE_EMAIL" \
  --log "$HOME/.acme.sh/acme.sh.log"
  "$ACME_SH_ARGS"
