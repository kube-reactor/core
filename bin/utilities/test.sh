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
  if [[ -d "${__test_dir}/${TEST_PHASE}" ]] \
    && compgen -G "${__test_dir}/${TEST_PHASE}"/*.sh > /dev/null; then
    for file in "${__test_dir}/${TEST_PHASE}"/*.sh; do
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
      export TEST_FILE="${file}"
      "$file"
    done
  fi
  if [[ -d "${__test_dir}/${TEST_PHASE}/commands" ]] \
    && compgen -G "${__test_dir}/${TEST_PHASE}/commands"/*.sh > /dev/null; then
    for file in "${__test_dir}/${TEST_PHASE}/commands"/*.sh; do
      if [[ "$arg_d" ]] || [[ "$arg_v" ]]; then
        add_space
        render "==========================================================================="
        render "+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++"
        render "+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++"
        render "+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++"
        render "==========================================================================="
      fi
      render " * Running reactor command test: $(key_color "${file}")"
      if [[ "$arg_d" ]] || [[ "$arg_v" ]]; then
        add_space
      fi

      export TEST_FILE="${file}"
      "$file"
    done
  fi
  if [[ -d "${__test_dir}/${TEST_PHASE}/utilities" ]] \
    && compgen -G "${__test_dir}/${TEST_PHASE}/utilities"/*.sh > /dev/null; then
    for file in "${__test_dir}/${TEST_PHASE}/utilities"/*.sh; do
      if [[ "$arg_d" ]] || [[ "$arg_v" ]]; then
        add_space
        render "==========================================================================="
        render "+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++"
        render "+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++"
        render "+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++"
        render "==========================================================================="
      fi
      render " * Running reactor utility test: $(key_color "${file}")"
      if [[ "$arg_d" ]] || [[ "$arg_v" ]]; then
        add_space
      fi

      export TEST_FILE="${file}"
      "$file"
    done
  fi
  if check_project; then
    #
    # Running Project Command Tests
    #
    if [[ -d "${__project_test_dir}/${TEST_PHASE}" ]] \
      && compgen -G "${__project_test_dir}/${TEST_PHASE}"/*.sh > /dev/null; then
      for file in "${__project_test_dir}/${TEST_PHASE}"/*.sh; do
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

        export TEST_FILE="${file}"
        "$file"
      done
    fi
    if [[ -d "${__project_test_dir}/${TEST_PHASE}/commands" ]] \
      && compgen -G "${__project_test_dir}/${TEST_PHASE}/commands"/*.sh > /dev/null; then
      for file in "${__project_test_dir}/${TEST_PHASE}/commands"/*.sh; do
        if [[ "$arg_d" ]] || [[ "$arg_v" ]]; then
          add_space
          render "==========================================================================="
          render "+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++"
          render "+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++"
          render "+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++"
          render "==========================================================================="
        fi
        render " * Running reactor command test: $(key_color "${file}")"
        if [[ "$arg_d" ]] || [[ "$arg_v" ]]; then
          add_space
        fi

        export TEST_FILE="${file}"
        "$file"
      done
    fi
    if [[ -d "${__project_test_dir}/${TEST_PHASE}/utilities" ]] \
      && compgen -G "${__project_test_dir}/${TEST_PHASE}/utilities"/*.sh > /dev/null; then
      for file in "${__project_test_dir}/${TEST_PHASE}/utilities"/*.sh; do
        if [[ "$arg_d" ]] || [[ "$arg_v" ]]; then
          add_space
          render "==========================================================================="
          render "+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++"
          render "+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++"
          render "+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++"
          render "==========================================================================="
        fi
        render " * Running reactor utility test: $(key_color "${file}")"
        if [[ "$arg_d" ]] || [[ "$arg_v" ]]; then
          add_space
        fi
        export TEST_FILE="${file}"
        "$file"
      done
    fi
  fi
}


function start_test () {
  export TEST_ERRORS=()
  export BASE_TEST_TAGS="$@"
  export TEST_TAGS=()
}

function fail () {
  local info="$(error_color "${TEST_PHASE:-}>${TEST_FILE:-}>${TEST_NAME:-}>${TEST_COMMAND:-} ]")"
  export TEST_ERRORS=("${TEST_ERRORS[@]}" "[ $info ]: $1")
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
    if declare -F "$test_function" >/dev/null; then
      render " ** Executing test function: $(value_color ${test_function})"
      export TEST_NAME="$test_function"
      "$test_function" "$@"
    else
      local info="$(error_color "${TEST_PHASE:-}>${TEST_FILE:-}")"
      render "[ ${info} ]: Function $(value_color ${test_function}) does not exist" 1>&2
      exit 1
    fi
  fi
}

function verify_test () {
  if [ ${#TEST_ERRORS[@]} -gt 0 ]; then
    for message in "${TEST_ERRORS[@]}"; do
      echo "$message" 1>&2
    done
    exit 1
  fi
}


source "${__utilities_dir}/verifiers.sh"

if check_project; then
  if [ -d "${__project_test_dir}/utilities" ]; then
    for file in "${__project_test_dir}/utilities"/*.sh; do
      source "$file"
    done
  fi
fi
