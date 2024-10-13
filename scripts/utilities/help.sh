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

$(IFS=$'\n'; echo "${__reactor_flags[*]}")


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
  echo "" >&2
  echo "" >&2
  echo "  Use '${__script_name} <command> --help' for more information about a given command" >&2
  echo "" >&2
  exit 1
}


function command_usage_argument_help () {
  local arguments="$(IFS=$'\n'; echo "${__reactor_arg_help[*]}")"
  if [ "$arguments" ]; then
    echo """

  Arguments:

$arguments
"""
  fi
}

function command_usage_flag_help () {
  local flags="$(IFS=$'\n'; echo "${__reactor_flags[*]}")"
  if [ "$flags" ]; then
    echo """

  Flags:

$flags
"""
  fi
}

function command_usage_option_help () {
  local options="$(IFS=$'\n'; echo "${__reactor_options[*]}")"
  if [ "$options" ]; then
    echo """

  Options:

$options
"""
  fi
}

function command_usage () {
  local command="$1"

  cat <<EOF >&2

  $(${command}_description)


  Usage:

    ${__script_name} ${command} [flags] [options] ${__reactor_args[@]}
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
