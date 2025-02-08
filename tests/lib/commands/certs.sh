#========================
# Certificate execution
#========================
#
# Search path
#
# test_{environment}_{phase}
# test_{environment}
# test_{phase}
# test_all
#

function verify_certs () {
  verify_file "${__certs_dir}/app-ca.crt"
  verify_file "${__certs_dir}/app-ca.key"
  verify_file "${__certs_dir}/app.crt"
  verify_file "${__certs_dir}/app.key"
}

function verify_no_certs () {
  verify_no_file "${__certs_dir}/app-ca.crt"
  verify_no_file "${__certs_dir}/app-ca.key"
  verify_no_file "${__certs_dir}/app.crt"
  verify_no_file "${__certs_dir}/app.key"
}

function verify_cert_headers () {
  verify_output "Application Certificate Authority key"
  verify_output "Application Certificate Authority certificate"
  verify_output "Application key"
  verify_output "Application certificate"
}


function display_empty_certs () {
  run_reactor certs
  verify_no_certs
  verify_cert_headers
}

function display_certs () {
  run_reactor certs
  verify_certs
  verify_cert_headers
}

function generate_default_certs () {
  run_reactor certs --generate
  verify_certs
}

function generate_custom_certs () {
  run_reactor certs --generate --subject="/C=US/ST=NY/L=New York/O=My Project" --days 90
  verify_certs
}

function test_seq () {
  tag certs build
  run_test display_empty_certs
  run_test generate_default_certs
  run_test generate_custom_certs
  run_test display_certs
}
