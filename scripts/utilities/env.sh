#
#=========================================================================================
# Command Environment Utilities
#

function current_environment () {
  ENVIRONMENT_VARS=()

  while IFS= read -r variable; do
    if [[ "$variable" != "HOSTNAME" ]] \
      && [[ "$variable" != "PATH" ]] \
      && [[ "$variable" != "PWD" ]] \
      && [[ "$variable" != "USER" ]] \
      && [[ "$variable" != "HOME" ]] \
      && [[ "$variable" != "SHELL" ]]; then

      ENVIRONMENT_VARS=("${ENVIRONMENT_VARS[@]}" "$variable")
    fi
  done <<< "$(env | grep -Po "[_A-Z0-9]{3,}=" | sed 's/\=//')"

  echo "${ENVIRONMENT_VARS[@]}"
}


function parse_environment () {
  local command="$1"
  local environment_function="${command}_command_environment"

  if function_exists "$environment_function"; then
    "$environment_function"
  fi
  if [ "${__reactor_arg_errors}" ]; then
    command_usage "$command"
    exit 1
  fi
}