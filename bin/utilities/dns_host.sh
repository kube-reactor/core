
if [[ "$__os" == "darwin" ]]; then
  export DEFAULT_HOSTS_FILE="/private/etc/hosts"
else
  export DEFAULT_HOSTS_FILE="/etc/hosts"
fi

function dns_environment_host () {
  export HOSTS_FILE="${HOSTS_FILE:-"$DEFAULT_HOSTS_FILE"}"
  export HOSTS_MANIFEST_FILE="$(logdir)/hosts.txt"

  debug "HOSTS_FILE: ${HOSTS_FILE}"
  debug "HOSTS_MANIFEST_FILE: ${HOSTS_MANIFEST_FILE}"
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


function save_dns_records_host () {
  # Runs on host machine (must be run after Kubernetes tunnel created)
  remove_dns_records_host

  info "Saving DNS records (requires sudo):"
  dns_records="$(dns_records)"
  printf "$dns_records" | sudo tee "$HOSTS_MANIFEST_FILE" >/dev/null 2>&1

  dns_records="$(cat "$HOSTS_MANIFEST_FILE")"

  info "$dns_records"
  printf "\n$dns_records" | sudo tee -a "$HOSTS_FILE" >/dev/null 2>&1
}

function remove_dns_records_host () {
  # Runs on host machine (requires sudo)
  if [ -f "${HOSTS_MANIFEST_FILE:-}" ]; then
    rm -f "$HOSTS_MANIFEST_FILE"
  fi

  if [ -f "${HOSTS_FILE:-}" ]; then
    info "Removing existing DNS records (requires sudo)"
    sudo perl -i -p0e "s/\n\#\#\#\!\s${APP_NAME}\sDNS\sMAP\s\!\#\#\#.+\#\#\#\!\sEND\s${APP_NAME}\sDNS\sMAP\s\!\#\#\#//se" "$HOSTS_FILE"
  fi
}
