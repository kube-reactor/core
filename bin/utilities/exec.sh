#
#=========================================================================================
# Command Execution Utilities
#

function check_project () {
  local command="$1"
  local check_function="${command}_check_project"

  if function_exists "$check_function"; then
    # Farm it off to a command level processor (create and test ...)
    "$check_function"
    return $?
  else
    if [[ ! "${__project_file}" ]]; then
      # Project does not exist
      return 1
    else
      # Project exists
      return 0
    fi
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
