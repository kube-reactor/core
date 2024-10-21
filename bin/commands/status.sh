#
#=========================================================================================
# <Status> Command
#

function status_description () {
  render "Check the status of a Kubernetes cluster"
}

function validate_sort_type () {
  if [[ "$1" != "cpu" ]] && [[ "$1" != "memory" ]]; then return 1; else return 0; fi
}

function status_command_environment () {
  parse_option --sort \
    TABLE_SORT \
    "Sort nodes and pods on 'memory' or 'cpu'" \
    "memory" \
    validate_sort_type \
    "Sort option must be either 'memory' or 'cpu'"

  namespace_option "" all
}

function status_command () {
  kubernetes_environment

  if ! kubernetes_status; then
    emergency "Kubernetes is not running"
  fi

  add_line "="
  render " Cluster Nodes"
  add_line "-"
  render "$(value_color "$("${__binary_dir}/kubectl" top node --show-capacity --sort-by="$TABLE_SORT" 2>&1)")"
  add_space

  POD_COMMAND=("top" "pod" "--sum" "--sort-by" "$TABLE_SORT")
  SERVICE_COMMAND=("get" "services")
  INGRESS_COMMAND=("get" "ingress")

  if [ "$SERVICE_NAMESPACE" != "all" ]; then
    NAMESPACE_OPTION=("-n" "$SERVICE_NAMESPACE")

    POD_COMMAND=("${POD_COMMAND[@]}" "${NAMESPACE_OPTION[@]}")
    SERVICE_COMMAND=("${SERVICE_COMMAND[@]}" "${NAMESPACE_OPTION[@]}")
    INGRESS_COMMAND=("${INGRESS_COMMAND[@]}" "${NAMESPACE_OPTION[@]}")
  else
    NAMESPACE_OPTION="--all-namespaces"

    POD_COMMAND=("${POD_COMMAND[@]}" "$NAMESPACE_OPTION")
    SERVICE_COMMAND=("${SERVICE_COMMAND[@]}" "$NAMESPACE_OPTION")
    INGRESS_COMMAND=("${INGRESS_COMMAND[@]}" "$NAMESPACE_OPTION")
  fi

  add_line "="
  render " Cluster Pods"
  add_line "-"
  render "$(value_color "$("${__binary_dir}/kubectl" "${POD_COMMAND[@]}" 2>&1)")"
  add_space

  add_line "="
  render " Cluster Services"
  add_line "-"
  render "$(value_color "$("${__binary_dir}/kubectl" "${SERVICE_COMMAND[@]}" 2>&1)")"
  add_space

  add_line "="
  render " Cluster Ingress"
  add_line "-"
  render "$(value_color "$("${__binary_dir}/kubectl" "${INGRESS_COMMAND[@]}" 2>&1)")"
  add_space
}
