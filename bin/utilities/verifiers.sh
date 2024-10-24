#
#=========================================================================================
# Command Test Verifier Library
#
# Note: This test library does not have access to the reactor environment.
#       It is loaded in a new terminal session by the run_session test script.
#
# Has access to directories:
#
# * __test_dir
# * __reactor_dir
# * __script_dir
# * __projects_dir
# * __project_dir
# * __project_test_dir
#
# Has access to state:
#
# * TEST_PHASE
# * TEST_FILE
# * TEST_NAME
# * TEST_COMMAND
# * TEST_OUTPUT
#

function verify_output () {
  if ! echo "${TEST_OUTPUT:-}" | grep -P "$1" 1>/dev/null 2>&1; then
    fail "Searched value ${1} was not found in command output"
  fi
}

function verify_no_output () {
  if echo "${TEST_OUTPUT:-}" | grep -P "$1" 1>/dev/null 2>&1; then
    fail "Searched value ${1} was found in command output"
  fi
}


function verify_dir () {
  if [ ! -d "$1" ]; then
    fail "Directory ${1} does not exist"
  fi
}

function verify_no_dir () {
  if [ -d "$1" ]; then
    fail "Directory ${1} exists"
  fi
}

function verify_file () {
  if [ ! -f "$1" ]; then
    fail "File ${1} does not exist"
  fi
}

function verify_no_file () {
  if [ -f "$1" ]; then
    fail "File ${1} exists"
  fi
}


function verify_host () {
  if ! cat /etc/hosts | grep "$1" 1>/dev/null 2>&1; then
    fail "Reactor host ${1} does not exist"
  fi
}

function verify_no_host () {
  if cat /etc/hosts | grep "$1" 1>/dev/null 2>&1; then
    fail "Reactor host ${1} exists"
  fi
}


function verify_command () {
  ORIG_OUTPUT="${TEST_OUTPUT:-}"
  "$1"
  export TEST_OUTPUT="$ORIG_OUTPUT"
}


function verify_docker_images () {
  local images="$@"
  function check_images () {
    run docker image list
    for image_name in ${images[@]}; do
      verify_output "^${image_name}\s+"
    done
  }
  verify_command check_images
}

function verify_no_docker_images () {
  local images="$@"
  function check_images () {
    run docker image list
    for image_name in ${images[@]}; do
      verify_no_output "^${image_name}\s+"
    done
  }
  verify_command check_images
}

function verify_docker_up () {
  local services="$@"
  function check_services () {
    run docker ps -a
    for service_name in ${services[@]}; do
      verify_output "\s+Up\s+.+\s+${service_name}(-|_)"
    done
  }
  verify_command check_services
}

function verify_docker_exit () {
  local services="$@"
  function check_services () {
    run docker ps -a
    for service_name in ${services[@]}; do
      verify_output "\s+Exited\s+.+\s+${service_name}(-|_)"
    done
  }
  verify_command check_services
}

function verify_helm_deployed () {
  local namespace="$1"
  shift

  local charts="$@"

  function check_charts () {
    run helm list -n "$namespace"
    for chart_name in ${charts[@]}; do
      verify_output "^${chart_name}\s+.+\s+deployed\s+"
    done
  }
  verify_command check_charts
}

function verify_argocd_synced () {
  local apps="$@"
  function check_apps () {
    run reactor argocd app list
    for app_name in ${apps[@]}; do
      verify_output "^${app_name}\s+.+\s+Synced\s+"
    done
  }
  verify_command check_apps
}

function verify_argocd_healthy () {
  local apps="$@"
  function check_apps () {
    run reactor argocd app list
    for app_name in ${apps[@]}; do
      verify_output "^${app_name}\s+.+\s+Synced\s+Healthy\s+"
    done
  }
  verify_command check_apps
}
