
function init_loader () {
  export CORE_INDEX=()
  export COMMAND_INDEX=()
  export UTILITY_INDEX=()

  if [[ ! -f "${__library_file}" ]] || [[ "${__app_args[0]}" == "build" ]] || [[ "$arg_r" ]]; then
    update_projects
  else
    load_libraries
  fi

  if ! is_setup_complete; then
    install_os_requirements
    install_python_requirements
    mark_setup_complete
  fi
}


function load_hook () {
  local lib_name="$1"
  if [[ "${2:-}" ]] || [[ ! " ${CORE_INDEX[*]} " =~ [[:space:]]${lib_name}[[:space:]] ]]; then
    local lib_script="${__core_lib_dir}/${lib_name}.sh"
    if [ -f "$lib_script" ]; then
      source "$lib_script"
    fi
    source_hook "$lib_name"
    export CORE_INDEX=("${CORE_INDEX[@]}" "$lib_name")
  fi
}


function parse_cli () {
  local param_function="$1"
  shift

  set_initialized
  reactor_args "$@"

  "$param_function"

  if [ "$arg_h" ]; then
    generic_usage "${HELP:-}"
  else
    render_overview
  fi
}
