#
#=========================================================================================
# Command Execution Utilities
#

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
