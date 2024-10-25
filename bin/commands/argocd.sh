#
#=========================================================================================
# <ArgoCD> Command
#

function argocd_description () {
  render "Execute a ArgoCD operation within the reactor environment context"
  export PASSTHROUGH="1"
}

function argocd_command () {
  helm_environment
  login_argocd
  "${__bin_dir}/argocd" "$@"
  add_space
}
