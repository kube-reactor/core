#
#=========================================================================================
# Certificate Utilities
#

export DEFAULT_CERT_SUBJECT="/C=US/ST=NY/L=New York/O=$(config name)"
export DEFAULT_CERT_DAYS=3650

function cert_environment () {
  debug "Setting certificate environment ..."
  export APP_CA_KEY="$(cat "${__certs_dir}/app-ca.key")"
  export APP_CA_CERT="$(cat "${__certs_dir}/app-ca.crt")"
  export APP_KEY="$(cat "${__certs_dir}/app.key")"
  export APP_CERT="$(cat "${__certs_dir}/app.crt")"

  debug "APP_CA_KEY: ${APP_CA_KEY}"
  debug "APP_CA_CERT: ${APP_CA_CERT}"
  debug "APP_KEY: ${APP_KEY}"
  debug "APP_CERT: ${APP_CERT}"
}


function display_certs () {
  cert_environment

  info "Application Certificate Authority key"
  echo "${APP_CA_KEY}"

  info ""
  info "Application Certificate Authority certificate"
  echo "${APP_CA_CERT}"

  info ""
  info "Application key"
  echo "${APP_KEY}"

  info ""
  info "Application certificate"
  echo "${APP_CERT}"
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
  rm -f "${__certs_dir}/app-ca.crt"
  rm -f "${__certs_dir}/app-ca.key"
  rm -f "${__certs_dir}/app.csr"
  rm -f "${__certs_dir}/app.crt"
  rm -f "${__certs_dir}/app.key"
}
