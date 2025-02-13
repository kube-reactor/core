#
#=========================================================================================
# DNS Utilities
#

function dns_environment () {
  debug "Setting DNS environment ..."
  export DNS_PROVIDER="${DNS_PROVIDER:-host}"

  debug "DNS_PROVIDER: ${DNS_PROVIDER}"

  run_dns_function dns_environment
}


function run_dns_function () {
  local base_name="$1"
  shift

  local provider_name="${base_name}_${DNS_PROVIDER}"
  debug "Running DNS function: ${provider_name}"

  if function_exists "$provider_name"; then
    "$provider_name" "$@"
  fi
  return $?
}


function dns_ip () {
  echo "$("${__bin_dir}/kubectl" get service nginx-nginx-ingress-controller -n nginx -o jsonpath='{.status.loadBalancer.ingress[*].ip}' 2>/dev/null)"
}

function dns_hostname () {
  echo "$("${__bin_dir}/kubectl" get service nginx-nginx-ingress-controller -n nginx -o jsonpath='{.status.loadBalancer.ingress[*].hostname}' 2>/dev/null)"
}

function dns_endpoint () {
  local ip="$(dns_ip)"
  if [ ! "$ip" ]; then
    ip="$(dns_hostname)"
  fi
  echo "$ip"
}

function dns_hosts () {
  echo "$("${__bin_dir}/kubectl" get ingress -A -o jsonpath='{.items[*].spec.rules[*].host}' 2>/dev/null)"
}


function save_dns_records () {
  dns_environment

  info "Waiting on Nginx ingress to initialize ..."
  while true; do
    dns_endpoint="$(dns_endpoint)"
    if [ ! -z "$dns_endpoint" ]; then
      break
    fi
    sleep 5
  done

  run_dns_function save_dns_records
}


function remove_dns_records () {
  dns_environment
  run_dns_function remove_dns_records
}
