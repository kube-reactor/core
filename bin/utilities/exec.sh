#
#=========================================================================================
# Command Execution Utilities
#

function export_functions () {
  # Export all functions so they are available in child scripts.
  for function_name in $(compgen -A function); do
    export -f "$function_name"
  done
}


function check_command () {
  local command="$1"
  local function="${command}_command"
  if function_exists "$function"; then
    return 0
  fi
  return 1
}

function run_command () {
  local command="$1"
  local command_function="${command}_${2}"
  shift; shift

  local command_args=("$@")

  if function_exists $command_function; then
    parse_environment "${command}"

    run_hook "${command_function}_initialize" \
      "$command" \
      "$command_function" \
      "${command_args[@]:-}"

    $command_function "${command_args[@]:-}"

    run_hook "${command_function}_finalize" \
      "$command" \
      "$command_function" \
      "${command_args[@]:-}"

  elif ! check_command "$command"; then
    error "Unknown command: ${command}"
    gateway_usage
  fi
}


function run_subcommand () {
  local command="$1"
  local args=("${@:2}")

  export __normalized_params="$(normalize_params "${args[@]}")"

  parse_environment "$command"
  "${command}_command" "${args[@]}"
}
