
function init_loader () {
  source "${__utilities_dir}/env.sh"
  source "${__utilities_dir}/hooks.sh"

  export CORE_INDEX=()
  export COMMAND_INDEX=()
  export UTILITY_INDEX=()

  load_utilities cli
}


function load_hook () {
  local lib_name="$1"
  if [[ ! " ${CORE_INDEX[*]:-} " =~ [[:space:]]${lib_name}[[:space:]] ]]; then
    local lib_script="${__core_lib_dir}/${lib_name}.sh"
    if [ -f "$lib_script" ]; then
      source "$lib_script"
    fi
    source_hook "$lib_name"
    export CORE_INDEX=("${CORE_INDEX[@]+"${CORE_INDEX[@]}"}" "$lib_name")
  fi
}

function load_utility () {
  local utility_name="$1"
  if [[ ! " ${UTILITY_INDEX[*]-} " =~ [[:space:]]${utility_name}[[:space:]] ]]; then
    echo "loading: $utility_name"
    source_utility "$utility_name"
    export UTILITY_INDEX=("${UTILITY_INDEX[@]+"${UTILITY_INDEX[@]}"}" "$utility_name")
  fi
}

function load_utilities () {
  if [ $# -gt 0 ]; then
    for library in $@; do
      load_utility "$library"
    done
  else
    load_library utilities
    run_hook initialize_utilities
  fi
}


function load_command () {
  local command_name="$1"
  if [[ ! " ${COMMAND_INDEX[*]:-} " =~ [[:space:]]${command_name}[[:space:]] ]]; then
    source "${__commands_dir}/${command_name}.sh"
    export COMMAND_INDEX=("${COMMAND_INDEX[@]+"${COMMAND_INDEX[@]}"}" "$command_name")
  fi
}

function load_commands () {
  if [ $# -gt 0 ]; then
    for command in $@; do
      load_command "$command"
    done
  else
    load_library commands
    run_hook initialize_commands
  fi
}


function parse_cli () {
  local param_function="$1"
  shift

  load_utilities help
  set_initialized
  reactor_args "$@"

  "$param_function"

  if [ "$arg_h" ]; then
    generic_usage "${HELP:-}"
  else
    render_overview
  fi
}
