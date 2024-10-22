#
#=========================================================================================
# Command Test Utilities
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
source "${__utilities_dir}/cli.sh"


function test_phase () {
  export TEST_PHASE="$1"
  export TEST_FILE=""

  #
  # Running Reactor Command Tests
  #
  if [ -d "${__test_dir}/${TEST_PHASE}" ]; then
    for file in "${__test_dir}/${TEST_PHASE}"/*.sh; do
      echo ""
      echo "==========================================================================="
      echo "+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++"
      echo "+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++"
      echo "+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++"
      echo "==========================================================================="
      echo " Running reactor test collection: ${file}"
      echo ""
      export TEST_FILE="${file}"
      "$file"
    done
  fi
  if [ -d "${__test_dir}/${TEST_PHASE}/commands" ]; then
    for file in "${__test_dir}/${TEST_PHASE}/commands"/*.sh; do
      echo ""
      echo "==========================================================================="
      echo "+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++"
      echo "+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++"
      echo "+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++"
      echo "==========================================================================="
      echo " Running reactor command test: ${file}"
      echo ""
      export TEST_FILE="${file}"
      "$file"
    done
  fi
  if [ -d "${__test_dir}/${TEST_PHASE}/utilities" ]; then
    for file in "${__test_dir}/${TEST_PHASE}/utilities"/*.sh; do
      echo ""
      echo "==========================================================================="
      echo "+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++"
      echo "+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++"
      echo "+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++"
      echo "==========================================================================="
      echo " Running reactor utility test: ${file}"
      echo ""
      export TEST_FILE="${file}"
      "$file"
    done
  fi
  #
  # Running Project Command Tests
  #
  if [ -d "${__project_test_dir}/${TEST_PHASE}" ]; then
    for file in "${__project_test_dir}/${TEST_PHASE}"/*.sh; do
      echo ""
      echo "==========================================================================="
      echo "+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++"
      echo "+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++"
      echo "+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++"
      echo "==========================================================================="
      echo " Running reactor test collection: ${file}"
      echo ""
      export TEST_FILE="${file}"
      "$file"
    done
  fi
  if [ -d "${__project_test_dir}/${TEST_PHASE}/commands" ]; then
    for file in "${__project_test_dir}/${TEST_PHASE}/commands"/*.sh; do
      echo ""
      echo "==========================================================================="
      echo "+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++"
      echo "+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++"
      echo "+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++"
      echo "==========================================================================="
      echo " Running reactor command test: ${file}"
      echo ""
      export TEST_FILE="${file}"
      "$file"
    done
  fi
  if [ -d "${__project_test_dir}/${TEST_PHASE}/utilities" ]; then
    for file in "${__project_test_dir}/${TEST_PHASE}/utilities"/*.sh; do
      echo ""
      echo "==========================================================================="
      echo "+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++"
      echo "+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++"
      echo "+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++"
      echo "==========================================================================="
      echo " Running reactor utility test: ${file}"
      echo ""
      export TEST_FILE="${file}"
      "$file"
    done
  fi
}


function start_test () {
  export TEST_ERRORS=()
  export BASE_TEST_TAGS="$@"
  export TEST_TAGS=()
}

function fail () {
  local message="[ ${TEST_PHASE} > ${TEST_FILE:-} > ${TEST_NAME:-} > ${TEST_COMMAND:-} ]: $1"
  export TEST_ERRORS=("${TEST_ERRORS[@]}" "$message")
}

function run () {
  local test_command="$1"
  shift

  export TEST_COMMAND="${test_command} ${@}"
  export TEST_OUTPUT="$($test_command "$@" | tee /dev/tty)"
}

function tag () {
  export TEST_TAGS="$@"
}

function run_test () {
  local test_function="$1"
  local run_test=0
  shift

  if [ ${#USER_TEST_TAGS[@]} -eq 0 ]; then
    # Proceed because no tags specified
    run_test=1
  else
    local test_tags=(
      "${BASE_TEST_TAGS[@]}"
      "${TEST_TAGS[@]}"
      "$test_function"
    )
    for user_tag in "${USER_TEST_TAGS[@]}"; do
      if echo "${test_tags[@]}" | grep -qw "$user_tag"; then
        # Proceed because we have a matching tag
        run_test=1
        break
      fi
    done
  fi

  if [ $run_test -eq 1 ]; then
    if declare -F "$1" >/dev/null; then
      export TEST_NAME="$test_function"
      "$test_function" "$@"
    else
      echo "[ ${TEST_PHASE} > ${TEST_FILE:-} ]: Function $1 does not exist" 1>&2
      exit 1
    fi
  fi
}

function verify_test () {
  if [ ${#TEST_ERRORS[@]} -gt 0 ]; then
    for message in ${TEST_ERRORS[@]}; do
      echo "$message" 1>&2
    done
    exit 1
  fi
}


source "${__utilities_dir}/verifiers.sh"

if [ -d "${__project_test_dir}/utilities" ]; then
  for file in "${__project_test_dir}/utilities"/*.sh; do
    source "$file"
  done
fi
