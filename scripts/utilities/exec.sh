#
#=========================================================================================
# Command Execution Utilities
#

function exec_command () {
  local command="$1"
  local args="${@:2}"

  export __normalized_params="$(normalize_params "${args[@]}")"

  parse_environment "$command"
  "${command}_command" "${args[@]}"
}

function exec_host_command () {
  local command="$1"
  local args="${@:2}"

  export __normalized_params="$(normalize_params "${args[@]}")"

  parse_environment "$command"
  "${command}_host_command" "${args[@]}"
}
