
function force_option () {
  local help_suffix="${1:-}"

  parse_flag --force \
    FORCE \
    "Force execution without confirming ${help_suffix}"
}

function wait_option () {
  local help_suffix="${1:-}"
  local default="${2:-2}"

  parse_option --wait \
    WAIT \
    "Amount of time to wait in seconds ${help_suffix}" \
    "$default"
}

function namespace_option () {
  local help_suffix="${1:-}"
  local default="${2:-default}"

  parse_option --namespace \
    SERVICE_NAMESPACE \
    "Kubernetes namespace ${help_suffix}" \
    "$default"
}

function pod_arg () {
  local help_suffix="${1:-}"

  parse_arg SERVICE_POD_NAME \
    "Kubernetes service pod name ${help_suffix}"
}

function service_image_arg () {
  local help_suffix="${1:-}"

  parse_arg SERVICE_IMAGE \
    "Kubernetes service container image ${help_suffix}"
}

function command_option () {
  local help_suffix="${1:-}"
  local default="${2:-bash}"

  parse_option --command \
    SERVICE_COMMAND \
    "Kubernetes service command ${help_suffix}" \
    "$default"
}

function required_command_args () {
  local help_suffix="${1:-}"

  parse_required_args SERVICE_COMMAND \
    "Kubernetes service command and optional arguments ${help_suffix}"
}

function optional_command_args () {
  local help_suffix="${1:-}"

  parse_optional_args SERVICE_COMMAND \
    "Kubernetes service command and optional arguments ${help_suffix}"
}

function cert_options () {
  local help_suffix="${1:-}"

  parse_option --subject \
    CERT_SUBJECT \
    "Certificate subject ${help_suffix}" \
    "$DEFAULT_CERT_SUBJECT"

  parse_option --days \
    CERT_DAYS \
    "Certificate lifespan ${help_suffix}" \
    "$DEFAULT_CERT_DAYS"
}

function image_build_options () {
  local help_suffix="${1:-}"

  parse_flag --no-cache \
    NO_CACHE \
    "Regenerate all intermediate images ${help_suffix}"
}
