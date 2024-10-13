#
#=========================================================================================
# <ArgoCD> Command
#

function argocd_description () {
  echo "Execute a ArgoCD operation within the reactor environment context"
  export PASSTHROUGH="1"
}

function argocd_command () {
  helm_environment
  "${__binary_dir}/argocd" "$@"
  echo ""
}
