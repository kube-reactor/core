#
#=========================================================================================
# DNS Utilities
#

if [[ "$__os" == "darwin" ]]; then
  export DEFAULT_HOSTS_FILE="/private/etc/hosts"
else
  export DEFAULT_HOSTS_FILE="/etc/hosts"
fi

function dns_environment () {
  debug "Setting DNS environment ..."
  export HOSTS_FILE="${HOSTS_FILE:-"$DEFAULT_HOSTS_FILE"}"
  export HOSTS_MANIFEST_FILE="$(logdir)/hosts.txt"

  debug "HOSTS_FILE: ${HOSTS_FILE}"
  debug "HOSTS_MANIFEST_FILE: ${HOSTS_MANIFEST_FILE}"
}


function dns_ip () {
  echo "$("${__binary_dir}/kubectl" get service nginx-nginx-ingress-controller -n nginx -o jsonpath='{.status.loadBalancer.ingress[*].ip}' 2>/dev/null)"
}

function dns_hosts () {
  echo "$("${__binary_dir}/kubectl" get ingress -A -o jsonpath='{.items[*].spec.rules[*].host}' 2>/dev/null)"
}

function dns_records () {
  dns_map=("###! $APP_NAME DNS MAP !###")

  for host in $(dns_hosts); do
    for ip in $(dns_ip); do
      dns_map=("${dns_map[@]}" "$ip $host")
    done
  done

  dns_map=("${dns_map[@]}" "###! END $APP_NAME DNS MAP !###")
  dns_map="$(printf "%s\n" "${dns_map[@]}")"
  echo "$dns_map"
}


function create_host_dns_records () {
  # Runs on host machine (must be run after Kubernetes tunnel created)
  dns_environment

  info "Waiting on Nginx ingress to initialize ..."
  while true; do
    dns_ip="$(dns_ip)"
    if [ ! -z "$dns_ip" ]; then
      break
    fi
    sleep 5
  done

  info "Saving DNS records (hosts.txt):"
  dns_records="$(dns_records)"
  printf "$dns_records" | sudo tee "$HOSTS_MANIFEST_FILE" >/dev/null 2>&1
}

function save_host_dns_records () {
  # Runs on host machine (requires sudo)
  dns_environment

  if [ -f "${HOSTS_MANIFEST_FILE:-}" ]; then
    remove_host_dns_records

    dns_records="$(cat "$HOSTS_MANIFEST_FILE")"

    info "Saving DNS records (requires sudo):"
    info "$dns_records"
    printf "\n$dns_records" | sudo tee -a "$HOSTS_FILE" >/dev/null 2>&1
  fi
}


function remove_dns_records () {
  dns_environment
  rm -f "$HOSTS_MANIFEST_FILE"
}

function remove_host_dns_records () {
  # Runs on host machine (requires sudo)
  dns_environment

  if [ -f "${HOSTS_FILE:-}" ]; then
    info "Removing existing DNS records (requires sudo)"
    sudo perl -i -p0e "s/\n\#\#\#\!\s${APP_NAME}\sDNS\sMAP\s\!\#\#\#.+\#\#\#\!\sEND\s${APP_NAME}\sDNS\sMAP\s\!\#\#\#//se" "$HOSTS_FILE"
  fi
}
