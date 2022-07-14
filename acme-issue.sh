#!/usr/bin/env bash
if [ ! -f "/etc/ssl/cert-domains.conf" ]; then
  printf '[%(%a %b %e %H:%M:%S %Z %Y)T] Config file /etc/ssl/cert-domains.conf not found\n' -1
  exit 255
fi

mapfile -t DOMAINS <"/etc/ssl/cert-domains.conf"
printf '[%(%a %b %e %H:%M:%S %Z %Y)T] Checking %d domains\n' -1 ${#DOMAINS[@]}
for ENTRY in "${DOMAINS[@]}"; do
  mapfile -td\, DOMAIN_INFO < <(printf "%s" "$ENTRY")
  printf -v DOMAIN_ARGS -- ' --domain %s' "${DOMAIN_INFO[@]%s'\n'}"
  printf -v ACME_ISSUE '%s/.acme.sh/acme.sh --issue --dns dns_cloudns --ecc' "$HOME"
  printf -v ACME_ISSUE '%s --home \"%s/.acme.sh\" --config-home \"%s\"' "$ACME_ISSUE" "$HOME" "$LE_CONFIG_HOME"
  printf -v ACME_ISSUE '%s --log %s/.acme.sh/acme.sh.log' "$ACME_ISSUE" "$HOME"
  printf -v ACME_ISSUE '%s --cert-home \"%s\" %s%s' "$ACME_ISSUE" "$LE_CERT_HOME" "$ACME_SH_ARGS" "${DOMAIN_ARGS[@]}"
  DOMAIN_PATH="$LE_CERT_HOME/${DOMAIN_INFO[0]}"
  if [ ! -d "$DOMAIN_PATH" ]; then
    eval "$ACME_ISSUE"
  fi
done
