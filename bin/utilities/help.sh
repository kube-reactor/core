#
#=========================================================================================
# Command Help Utilities
#

function usage () {
  cat <<EOF >&2

  Reactor manages development Kubernetes environments


  Usage:

    ${__script_name} [flags] [command] [flags/options]


  Flags:

$(IFS=$'\n'; render "${__reactor_flags[*]}")


  Commands:

    enter                          Launch a reactor container session
EOF
  for function_name in $(compgen -A function); do
    if [[ "$function_name" == *"_command" ]]; then
      command_name=${function_name%"_command"}
      command_description="${command_name}_description"

      if function_exists $command_description; then
        printf "    %-30s %s\n" "$command_name" "$($command_description)" >&2
      fi
    fi
  done
  add_space
  add_space
  render "  Use '${__script_name} <command> --help' for more information about a given command"
  add_space
  exit 1
}


function command_usage_argument_help () {
  local arguments="$(IFS=$'\n'; echo "${__reactor_arg_help[*]}")"
  if [ "$arguments" ]; then
    render """

  Arguments:

$arguments
"""
  fi
}

function command_usage_flag_help () {
  local flags="$(IFS=$'\n'; echo "${__reactor_flags[*]}")"
  if [ "$flags" ]; then
    render """

  Flags:

$flags
"""
  fi
}

function command_usage_option_help () {
  local options="$(IFS=$'\n'; echo "${__reactor_options[*]}")"
  if [ "$options" ]; then
    render """

  Options:

$options
"""
  fi
}

function command_usage () {
  local command="$1"
  local help_text=""

  if function_exists "${command}_help"; then
    help_content="$(${command}_help)"
    help_text="""

  $(format_width "$help_content" 2)
"""
  fi

  cat <<EOF >&2

  $(${command}_description) ${help_text}


  Usage:

    ${__script_name} ${command} $(key_color "[flags] [options]") ${__reactor_args[@]}
$(command_usage_argument_help) $(command_usage_flag_help) $(command_usage_option_help)

EOF
  exit 1
}


function generate_command_help () {
  local command="$1"
  local help_environment="${command}_command_environment"

  if function_exists $help_environment; then
    $help_environment
  fi
  command_usage "${command}"
}
