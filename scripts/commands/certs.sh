#
#=========================================================================================
# <Certs> Command
#

function certs_description () {
  echo "Display or generate self signed SSL certificates"
}

function certs_command_environment () {
  parse_flag --generate \
    GENERATE \
    "Generate certificates before displaying them"

  parse_option --subject \
    CERT_SUBJECT \
    "Certificate subject (requires --generate)" \
    "$DEFAULT_CERT_SUBJECT"

  parse_option --days \
    DAYS \
    "Certificate lifespan (requires --generate)" \
    "$DEFAULT_CERT_DAYS"
}

function certs_command () {
  SUBJECT="${SUBJECT}/CN=*.${PRIMARY_DOMAIN}"

  debug "> SUBJECT: ${SUBJECT}"

  if [ "$GENERATE" ]; then
    generate_certs "$SUBJECT" $DAYS
  fi
  display_certs

  exec_hook certs
}
