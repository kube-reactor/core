#
#=========================================================================================
# Command Execution Utilities
#

function requires_project () {
  local command="$1"
  local check_function="${command}_requires_project"

  if function_exists "$check_function"; then
    # Farm it off to a command level processor (create and test ...)
    "$check_function"
    return $?
  else
    # All commands by default run in containers before host execution
    return 0
  fi
}


function run_command () {
  local command="$1"
  local args="${@:2}"

  export __normalized_params="$(normalize_params "${args[@]}")"

  parse_environment "$command"
  "${command}_command" "${args[@]}"
}

function run_host_command () {
  local command="$1"
  local args="${@:2}"

  export __normalized_params="$(normalize_params "${args[@]}")"

  parse_environment "$command"
  "${command}_host_command" "${args[@]}"
}
