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
# * __bin_dir
# * __projects_dir
# * __project_dir
# * __project_test_dir
#
load_utilities cli verifiers


function test_phase () {
  export TEST_PHASE="$1"
  export TEST_FILE=""
  #
  # Running Reactor Command Tests
  #
  if [[ -d "${__test_lib_dir}" ]] \
    && compgen -G "${__test_lib_dir}"/**/*.sh > /dev/null; then
    for file in "${__test_lib_dir}"/**/*.sh; do
      if [[ "$arg_d" ]] || [[ "$arg_v" ]]; then
        add_space
        render "==========================================================================="
        render "+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++"
        render "+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++"
        render "+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++"
        render "==========================================================================="
      fi
      render " * Running reactor test collection: $(key_color "${file}")"
      if [[ "$arg_d" ]] || [[ "$arg_v" ]]; then
        add_space
      fi
      run_test_sequence "$TEST_PHASE" "$file"
    done
  fi
  if check_project; then
    #
    # Running Project Command Tests
    #
    if [[ -d "${__project_test_dir}" ]] \
      && compgen -G "${__project_test_dir}"/**/*.sh > /dev/null; then
      for file in "${__project_test_dir}"/**/*.sh; do
        if [[ "$arg_d" ]] || [[ "$arg_v" ]]; then
          add_space
          render "==========================================================================="
          render "+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++"
          render "+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++"
          render "+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++"
          render "==========================================================================="
        fi
        render " * Running reactor test collection: $(key_color "${file}")"
        if [[ "$arg_d" ]] || [[ "$arg_v" ]]; then
          add_space
        fi
        run_test_sequence "$TEST_PHASE" "$file"
      done
    fi
  fi
  export TEST_PHASE=""
  export TEST_FILE=""
}


function start_test () {
  export TEST_SILENCED=0
  export TEST_ERRORS=()
  export TEST_MESSAGES=()
  export BASE_TEST_TAGS=("$@")
  export TEST_TAGS=()
}

function fail () {
  INFO_DATA=()
  if [ "${TEST_PHASE:-}" ]; then
    INFO_DATA=("${INFO_DATA[@]}" "$(alert_color "$TEST_PHASE")")
  fi
  if [ "${TEST_FILE:-}" ]; then
    INFO_DATA=("${INFO_DATA[@]}" "$(warning_color "$TEST_FILE")")
  fi
  if [ "${TEST_NAME:-}" ]; then
    INFO_DATA=("${INFO_DATA[@]}" "$(value_color "$TEST_NAME")")
  fi

  local info_string="${INFO_DATA[*]}"
  local info="$(error_color "${info_string// / > }") ${TEST_COMMAND:-}"
  local message="$(error_color "$1")"

  if [ $TEST_SILENCED -eq 0 ]; then
    render " *** ${message}"
  fi
  export TEST_ERRORS=("${TEST_ERRORS[@]}" "[ $info ]: $1")
  export TEST_MESSAGES=("${TEST_MESSAGES[@]}" " *** ${message}")
}

function run () {
  local test_command="$1"
  local log_file="$(logdir)/$(echo "$*" | tr -d ' ').log"
  shift

  export TEST_COMMAND="${test_command} ${@}"

  debug ""
  debug "Running:"
  debug ""
  debug "Command: ${TEST_COMMAND}"
  debug "Log File: ${log_file}"

  "$test_command" "$@" 1>"$log_file" 2>&1
  export TEST_STATUS=$?
  export TEST_OUTPUT="$(cat "$log_file")"

  debug "Output: ${TEST_OUTPUT}"
  debug "Status:  ${TEST_STATUS}"
  debug ""

  if [ $TEST_STATUS -ne 0 ]; then
    fail "Command failed: ${test_command} ${@} [ ${log_file} ]"
  fi
}

function render_output () {
  render "${TEST_OUTPUT:-}"
}

function wait () {
  local test_function="$1"
  local max_tries="${2:-10}"
  local wait_secs="${3:-1}"

  if [ "${TEST_NO_WAIT:-}" ]; then
    max_tries=1
  fi
  local ORIG_ERRORS=("${TEST_ERRORS[@]}")

  for iteration in $(seq 1 $max_tries); do
    export TEST_ERRORS=()
    export TEST_MESSAGES=()
    export TEST_SILENCED=1

    $test_function

    if [ ${#TEST_ERRORS[@]} -eq 0 ]; then
      export TEST_ERRORS=("${ORIG_ERRORS[@]}")
      break
    else
      export TEST_ERRORS=("${ORIG_ERRORS[@]}" "${TEST_ERRORS[@]}")
      for message in "${TEST_MESSAGES[@]}"; do
        render "$message" 1>&2
      done
    fi
    sleep $wait_secs
  done
  export TEST_SILENCED=0
}

function tag () {
  export SECTION_TEST_TAGS=("$@")
  export TEST_TAGS=()
}

function add_tag () {
  export TEST_TAGS=("$@")
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
      "${SECTION_TEST_TAGS[@]}"
      "${TEST_TAGS[@]}"
      "$test_function"
    )
    if [ "${TEST_PHASE:-}" ]; then
      test_tags=("${test_tags[@]}" "$TEST_PHASE")
    fi
    for user_tag in "${USER_TEST_TAGS[@]}"; do
      if echo "${test_tags[@]}" | grep -qw "$user_tag"; then
        # Proceed because we have a matching tag
        run_test=1
        break
      fi
    done
  fi

  if [ $run_test -eq 1 ]; then
    if declare -F "$test_function" >/dev/null; then
      render " ** Executing test function: $(value_color ${test_function})"
      export TEST_NAME="$test_function"
      "$test_function" "$@"
      export TEST_NAME=""
      export TEST_COMMAND=""
    else
      INFO_DATA=()
      if [ "${TEST_PHASE:-}" ]; then
        INFO_DATA=("${INFO_DATA[@]}" "$TEST_PHASE")
      fi
      if [ "${TEST_FILE:-}" ]; then
        INFO_DATA=("${INFO_DATA[@]}" "$(warning_color "$TEST_FILE")")
      fi
      local info_string="${INFO_DATA[*]}"
      local info="$(error_color "${info_string// / > }")"
      render "[ ${info} ]: Function $(value_color ${test_function}) does not exist" 1>&2
      exit 1
    fi
  fi
}

function run_test_sequence () {
  local test_phase="$1"
  local test_found=0

  local env_phase_test="test_${__environment}_${test_phase}"
  local env_test="test_${__environment}"
  local phase_test="test_${test_phase}"
  local all_test="test_all"

  unset -f "$env_phase_test"
  unset -f "$env_test"
  unset -f "$phase_test"
  unset -f "$all_test"

  export TEST_FILE="$2"
  source "$TEST_FILE"

  if function_exists "$env_phase_test"; then
    "$env_phase_test" "$TEST_FILE"
    test_found=1
  fi
  if function_exists "$env_test"; then
    "$env_test" "$TEST_FILE"
    test_found=1
  fi
  if function_exists "$phase_test"; then
    "$phase_test" "$TEST_FILE"
    test_found=1
  fi
  if function_exists "$all_test"; then
    "$all_test" "$TEST_FILE"
    test_found=1
  fi
  if [ $test_found -ne 1 ]; then
    warning "No test functions defined: ${env_phase_test}, ${env_test}, ${phase_test}, ${all_test}"
  fi
}

function verify_test () {
  if [ ${#TEST_ERRORS[@]} -gt 0 ]; then
    add_space
    for message in "${TEST_ERRORS[@]}"; do
      render "$message" 1>&2
    done
    exit 1
  fi
}
