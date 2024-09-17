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