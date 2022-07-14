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
  DOMAIN_CERT="$DOMAIN_PATH/${DOMAIN_INFO[0]}.cer"
  printf "Domain Path: %s" "${DOMAIN_PATH}"
  printf "Domain Cert: %s" "${DOMAIN_CERT}"
  if [ ! -f "$DOMAIN_CERT" ]; then
    eval "$ACME_ISSUE"
  fi
  printf -v ACME_DEPLOY '%s/.acme.sh/acme.sh --deploy' "$HOME"
  printf -v ACME_DEPLOY '%s%s' "$ACME_DEPLOY" "${DOMAIN_ARGS[@]}"
  printf -v ACME_DEPLOY '%s --deploy-hook haproxy' "$ACME_DEPLOY"
  if [ -f "$DOMAIN_CERT" ]; then
    printf "%s" "${ACME_DEPLOY}"
    eval "$ACME_DEPLOY"
  fi
done
