#
#=========================================================================================
# Command Execution Utilities
#
load_utilities env hooks args


function export_functions () {
  # Export all functions so they are available in child scripts.
  for function_name in $(compgen -A function); do
    export -f "$function_name"
  done
}

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


function check_command () {
  local command="$1"

  for function_suffix in ${__reactor_command_functions[@]}; do
    local function="${command}_${function_suffix}"
    if function_exists "$function"; then
      return 0
    fi
  done
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
  local args="${@:2}"

  export __normalized_params="$(normalize_params "${args[@]}")"

  parse_environment "$command"
  "${command}_command" "${args[@]}"
}

function run_host_subcommand () {
  local command="$1"
  local args="${@:2}"

  export __normalized_params="$(normalize_params "${args[@]}")"

  parse_environment "$command"
  "${command}_host_command" "${args[@]}"
}
