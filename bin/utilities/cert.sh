#
#=========================================================================================
# Certificate Utilities
#

export DEFAULT_CERT_SUBJECT="/C=US/ST=NY/L=New York/O=$(config name)"
export DEFAULT_CERT_DAYS=3650


function cert_environment () {
  debug "Setting certificate environment ..."
  export CERT_SUBJECT="${CERT_SUBJECT:-$DEFAULT_CERT_SUBJECT}"
  export CERT_DAYS="${CERT_DAYS:-$DEFAULT_CERT_DAYS}"

  if [ -f "${__certs_dir}/app-ca.key" ]; then
    APP_CA_KEY="$(cat "${__certs_dir}/app-ca.key")"
  else
    APP_CA_KEY=""
  fi
  export APP_CA_KEY

  if [ -f "${__certs_dir}/app-ca.crt" ]; then
    APP_CA_CERT="$(cat "${__certs_dir}/app-ca.crt")"
  else
    APP_CA_CERT=""
  fi
  export APP_CA_CERT

  if [ -f "${__certs_dir}/app.key" ]; then
    APP_KEY="$(cat "${__certs_dir}/app.key")"
  else
    APP_KEY=""
  fi
  export APP_KEY

  if [ -f "${__certs_dir}/app.crt" ]; then
    APP_CERT="$(cat "${__certs_dir}/app.crt")"
  else
    APP_CERT=""
  fi
  export APP_CERT

  debug "CERT_SUBJECT: ${CERT_SUBJECT}"
  debug "CERT_DAYS: ${CERT_DAYS}"
  debug "APP_CA_KEY: ${APP_CA_KEY}"
  debug "APP_CA_CERT: ${APP_CA_CERT}"
  debug "APP_KEY: ${APP_KEY}"
  debug "APP_CERT: ${APP_CERT}"
}


function display_certs () {
  cert_environment

  info "Application Certificate Authority key"
  render "${APP_CA_KEY}"

  info ""
  info "Application Certificate Authority certificate"
  render "${APP_CA_CERT}"

  info ""
  info "Application key"
  render "${APP_KEY}"

  info ""
  info "Application certificate"
  render "${APP_CERT}"
}

function generate_certs () {
  CERT_SUBJECT="$1"
  CERT_DAYS="$2"

  if [ \
    -f "${__certs_dir}/app-ca.crt" -a \
    -f "${__certs_dir}/app-ca.key" -a \
    -f "${__certs_dir}/app.crt" -a \
    -f "${__certs_dir}/app.key" \
  ]; then
    return 0
  fi

  info "Generating root CA private key and certificate ..."
  openssl req -new -x509 -sha256 -nodes -days $CERT_DAYS -newkey rsa:4096 \
    -subj "$CERT_SUBJECT" \
    -keyout "${__certs_dir}/app-ca.key" \
    -out "${__certs_dir}/app-ca.crt" >/dev/null 2>&1

  info "Generating server private key and certificate signing request ..."
  openssl req -new -sha256 -nodes -days $CERT_DAYS -newkey rsa:4096 \
    -subj "$CERT_SUBJECT" \
    -keyout "${__certs_dir}/app.key" \
    -out "${__certs_dir}/app.csr" >/dev/null 2>&1

  info "Generating server certificate through root CA ..."
  openssl x509 -req -CAcreateserial \
    -CA "${__certs_dir}/app-ca.crt" \
    -CAkey "${__certs_dir}/app-ca.key" \
    -in "${__certs_dir}/app.csr" \
    -out "${__certs_dir}/app.crt" >/dev/null 2>&1
}

function clean_certs () {
  info "Cleaning server certificates ..."
  rm -Rf "${__certs_dir}"
}
