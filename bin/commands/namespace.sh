#
#=========================================================================================
# <Namespace> Command
#

function namespace_description () {
  render "Run an operation on a namespace"
}

function namespace_command_environment () {
  parse_flag --destroy \
    DESTROY \
    "Force destruction of the namespace"

  parse_arg NAMESPACE "Name of the namespace"
}

function namespace_command () {
  kubernetes_environment

  if ! kubernetes_status; then
    emergency "Kubernetes is not running"
  fi
  if [ "$DESTROY" ]; then
    "${__bin_dir}/kubectl" get namespace "$NAMESPACE" -o json \
      | tr -d "\n" | sed "s/\"finalizers\": \[[^]]\+\]/\"finalizers\": []/" \
      | "${__bin_dir}/kubectl" replace --raw "/api/v1/namespaces/${NAMESPACE}/finalize" -f - 1>"$(logfile)" 2>&1

    info "Namepace ${NAMESPACE} has been destroyed"
  else
    "${__bin_dir}/kubectl" get namespace "$NAMESPACE"
  fi
}
