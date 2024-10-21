#
#=========================================================================================
# <Certs> Command
#

function certs_description () {
  render "Display or generate self signed SSL certificates"
}

function certs_command_environment () {
  parse_flag --generate \
    GENERATE \
    "Generate certificates before displaying them"

  cert_options "(requires --generate)"
}

function certs_command () {
  CERT_SUBJECT="${CERT_SUBJECT}/CN=*.${PRIMARY_DOMAIN}"

  debug "> CERT_SUBJECT: ${CERT_SUBJECT}"

  if [ "$GENERATE" ]; then
    generate_certs "$CERT_SUBJECT" $CERT_DAYS
  fi
  display_certs

  run_hook certs
}
