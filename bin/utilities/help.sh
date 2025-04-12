#
#=========================================================================================
# Command Help Utilities
#

#
#=========================================================================================
# Help Generation
#

function generate_command_help () {
  local command="$1"
  local help_environment="${command}_command_environment"

  if function_exists $help_environment; then
    $help_environment
  fi
  command_usage "${command}"
}

#
#=========================================================================================
# Reactor Usage Information
#

function gateway_usage () {
  render_overview
  cat <<EOF >&2
  Reactor manages development Kubernetes environments


  Usage:

    ${__script_name} [flags] [command] [flags/options]


  Flags:

$(IFS=$'\n'; render "${__reactor_flags[*]}")


  Commands:

EOF
  for function_name in $(compgen -A function); do
    if [[ "$function_name" == *"_description" ]]; then
      command_name=${function_name%"_description"}
      printf "    %-30s %s\n" "$(value_color $command_name)" "$($function_name)" >&2
    fi
  done
  add_space
  add_space
  render "  Use '${__script_name} <command> --help' for more information about a given command"
  add_space
  exit 1
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

  render_overview
  cat <<EOF >&2

  $(${command}_description) ${help_text}


  Usage:

    ${__script_name} ${command} $(key_color "[flags] [options]") ${__reactor_args[@]}
$(command_usage_argument_help) $(command_usage_flag_help) $(command_usage_option_help)

EOF
  exit 1
}

function generic_usage () {
  local description="$1"

  render_overview
  cat <<EOF >&2

  ${description}

  Usage:

    ${__script_name} $(key_color "[flags] [options]") ${__reactor_args[@]}
$(command_usage_argument_help) $(command_usage_flag_help) $(command_usage_option_help)

EOF
  exit 1
}

#
#=========================================================================================
# Usage Rendering (Flags, Options, Arguments)
#

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
