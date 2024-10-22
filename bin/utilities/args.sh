#
#=========================================================================================
# Command Argument Utilities
#
source "${__utilities_dir}/cli.sh"
source "${__utilities_dir}/validators.sh"
source "${__utilities_dir}/arg_lib.sh"

#
#=========================================================================================
# Argument Initialization
#

function reactor_args () {
  export __app_args=("$@")
  export __normalized_params="$(normalize_params "$@")"
  export __reactor_flags=()
  export __reactor_options=()
  export __reactor_args=()
  export __reactor_arg_help=()
  export __reactor_arg_errors=""

  parse_flag '-n|--no-color' arg_n "Disable color output"
  parse_flag '-h|--help' arg_h "Display help message"
  parse_flag '-v|--verbose' arg_v "Enable verbose mode, print script as it is executed"
  parse_flag '-d|--debug' arg_d "Enables debug mode"

  # Error handling
  set -o errexit
  set -o errtrace
  set -o nounset
  set -o pipefail

  # Log check
  [[ "${LOG_LEVEL:-6}" ]] || emergency "Cannot continue without LOG_LEVEL"

  # Debug mode
  if [ "$arg_d" ]; then
    #set -o xtrace
    export PS4='+(${BASH_SOURCE}:${LINENO}): ${FUNCNAME[0]:+${FUNCNAME[0]}(): }'
    export LOG_LEVEL="7"
    # Enable error backtracing
    trap '__err_report "${FUNCNAME:-.}" ${LINENO}' ERR
  fi

  # Verbose mode
  if [ "$arg_v" ]; then
    set -o verbose
  fi

  debug ""
  debug "Command Arguments"
  debug "======================================"
  debug "> App Args: ${__app_args[@]}"
  debug "> Normalized Args: ${__normalized_params}"
  debug ""

  debug "Top level flags"
  debug "======================================"
  debug "> Debug: ${arg_d}"
  debug "> Verbosity: ${arg_v}"
  debug "> Help: ${arg_h}"
  debug ""
}

function normalize_params () {
  local PARAMS=''

  for PARAM in "$@"; do
    # Split single character flags
    if [[ $PARAM =~ ^-([A-Za-z0-9]{2,})$ ]]; then
      BLOB=${BASH_REMATCH[1]}
      for ((i=0; i<${#BLOB}; i++)); do
        PARAMS="${PARAMS}-${BLOB:$i:1}"$'\n'
      done
    # Split equal '=' assignments
    elif [[ $PARAM =~ ^(--?[A-Za-z0-9_-]+)\=(.+)$ ]]; then
      PARAMS="${PARAMS}${BASH_REMATCH[1]}"$'\n'
      PARAMS="${PARAMS}${BASH_REMATCH[2]}"$'\n'
    else
      PARAMS="${PARAMS}${PARAM}"$'\n'
    fi
  done
  echo "$PARAMS"
}

function pop_arg_command () {
  local ALT_PARAMS=''
  local IFS_ORIG="$IFS"
  local FIRST=''

  IFS=$'\n'
  for PARAM in ${__normalized_params}; do
    if [ ! -z "$FIRST" ]; then
      ALT_PARAMS="${ALT_PARAMS}${PARAM}"$'\n'
    fi
    FIRST="1"
  done

  __normalized_params=$ALT_PARAMS
  IFS="$IFS_ORIG"
}

#
#=========================================================================================
# Argument Parsing
#

#-----------------------------------------------------------------------------------------
# Flags (Booleans)

function parse_flag () {
  local FLAGS="$1"
  local FOUND_REF="$2"
  local HELP_TEXT="$3"

  local LOCAL_FOUND=''

  local ALT_PARAMS=''
  local IFS_ORIG="$IFS"

  eval $FOUND_REF=''

  IFS='|'
  read -ra FLAG_ARRAY <<< "$FLAGS"

  IFS=$'\n'
  for PARAM in ${__normalized_params}; do
    for FLAG in "${FLAG_ARRAY[@]}"; do
      if [ "$PARAM" = "$FLAG" ]; then
        eval $FOUND_REF=1
        LOCAL_FOUND='1'
        break
      fi
    done

    if [ ! "$LOCAL_FOUND" ]; then
      ALT_PARAMS="${ALT_PARAMS}${PARAM}"$'\n'
    fi

    LOCAL_FOUND=''
  done
  IFS="$IFS_ORIG"

  local NAME=$(variable_color "\$$FOUND_REF")

  __reactor_flags=(
    "${__reactor_flags[@]}"
    "    $(printf %-35s "$(key_color "${FLAGS//|/ }")") [ ${NAME} ] ${HELP_TEXT}"
  )
  __normalized_params=$ALT_PARAMS

  debug "> ${FLAGS//|/ }: ${!FOUND_REF}"
}

#-----------------------------------------------------------------------------------------
# Options (Optional Single Values)

function parse_option () {
  local OPTIONS="$1"
  local VALUE_REF="$2"
  local NAME=$(variable_color "\$$VALUE_REF")
  local HELP_TEXT="$3"
  local VALUE_DEFAULT="${4:-}"
  local VALIDATOR="${5:-"validate_string"}"
  local ERROR_MSG="${6:-"Option ${OPTIONS//|/ } ${VALIDATOR} failed"}"

  local ALT_PARAMS=''
  local IFS_ORIG="$IFS"

  local OPTION_FOUND=''
  local VALUE_FOUND=''
  local NEEDS_PROCESSING=''

  eval $VALUE_REF="'$VALUE_DEFAULT'"

  IFS='|'

  __reactor_options=(
    "${__reactor_options[@]}"
    "    $(printf %-35s "$(key_color "${OPTIONS//|/ }") <value>") [ ${NAME} ] ${HELP_TEXT} ($(value_color "${VALUE_DEFAULT}"))"
  )
  read -ra OPTION_ARRAY <<< "$OPTIONS"

  IFS=$'\n'
  for PARAM in ${__normalized_params}; do
    if [ "$NEEDS_PROCESSING" ]; then
      if [[ $PARAM =~ ^- ]]; then
        ERROR_MSG="$(render "Parameter [ $OPTIONS ] (empty): $ERROR_MSG")"
        error "$ERROR_MSG"

        IFS="$IFS_ORIG"
        __reactor_arg_errors="1"
      fi

      if [[ ! "$arg_h" ]] && [[ "$VALIDATOR" ]]; then
        if ! $VALIDATOR "$PARAM"; then
          error "Parameter [ $OPTIONS ] ($PARAM): $ERROR_MSG"
          __reactor_arg_errors="1"
        fi
      fi
      eval $VALUE_REF="'$PARAM'"
      VALUE_FOUND='1'
      NEEDS_PROCESSING=''
      continue
    fi

    for OPTION in "${OPTION_ARRAY[@]}"; do
      if [ "$PARAM" = "$OPTION" ]; then
       	OPTION_FOUND='1'
        NEEDS_PROCESSING='1'
        break
      fi
    done

    if [ ! "$NEEDS_PROCESSING" ]; then
      ALT_PARAMS="${ALT_PARAMS}${PARAM}"$'\n'
    fi
  done

  if [[ ! "$arg_h" ]] && [[ "$OPTION_FOUND" ]] && [[ ! "$VALUE_FOUND" ]]; then
    error "Parameter [ $OPTIONS ] (empty): $ERROR_MSG"

    IFS="$IFS_ORIG"
    __reactor_arg_errors="1"
  fi

  __normalized_params=$ALT_PARAMS
  IFS="$IFS_ORIG"

  debug "> ${OPTIONS//|/ }: ${!VALUE_REF}"
}

#-----------------------------------------------------------------------------------------
# Arguments (Required Single Values)

function parse_arg () {
  local VALUE_REF="$1"
  local NAME=$(key_color "$(lowercase ${VALUE_REF})")
  local VARIABLE_NAME=$(variable_color "\$${VALUE_REF}")
  local HELP_TEXT="$2"
  local VALIDATOR="${3:-"validate_string"}"
  local ERROR_MSG="${4:-"Argument ${NAME} ${VALIDATOR} failed"}"

  local ALT_PARAMS=''
  local IFS_ORIG="$IFS"

  local VALUE_FOUND=''

  eval $VALUE_REF=""

  __reactor_args=(
    "${__reactor_args[@]}"
    "$(lowercase "${VALUE_REF}")"
  )
  __reactor_arg_help=(
    "${__reactor_arg_help[@]}"
    "    $(printf %-35s "${NAME}") [ ${VARIABLE_NAME} ] ${HELP_TEXT} $(alert_color "(REQUIRED)")"
  )

  IFS=$'\n'
  for PARAM in ${__normalized_params}; do
    if [[ $PARAM =~ ^[^-] ]] && [[ ! "$VALUE_FOUND" ]]; then
      if [[ ! "$arg_h" ]] && [[ "$VALIDATOR" ]]; then
        if ! $VALIDATOR "$PARAM"; then
          error "Parameter [ $NAME ] ($PARAM): $ERROR_MSG"
          __reactor_arg_errors="1"
        fi
      fi
      if [ -z "${__reactor_arg_errors}" ]; then
        eval $VALUE_REF="'$PARAM'"
        VALUE_FOUND='1'
      fi
    else
      ALT_PARAMS="${ALT_PARAMS}${PARAM}"$'\n'
    fi
  done

  if [[ ! "$arg_h" ]] && [[ ! "$VALUE_FOUND" ]]; then
    error "Parameter [ $NAME ] (empty): $ERROR_MSG"

    IFS="$IFS_ORIG"
    __reactor_arg_errors="1"
  fi

  __normalized_params=$ALT_PARAMS
  IFS="$IFS_ORIG"

  debug "> ${NAME}: ${!VALUE_REF}"
}

#-----------------------------------------------------------------------------------------
# Arguments (Required or Optional Multi Values)

function parse_optional_args () {
  local VALUE_REF="$1"
  local NAME=$(key_color "$(lowercase ${VALUE_REF})")
  local VARIABLE_NAME=$(variable_color "\${${VALUE_REF}[@]}")
  local HELP_TEXT="$2"

  local IFS_ORIG="$IFS"
  local ARGS=()

  __reactor_args=(
    "${__reactor_args[@]}"
    "[ $(lowercase "${VALUE_REF}") ... ]"
  )
  __reactor_arg_help=(
    "${__reactor_arg_help[@]}"
    "    $(printf %-35s "${NAME} ...") [ ${VARIABLE_NAME} ] ${HELP_TEXT} (OPTIONAL)"
  )

  IFS=$'\n'
  for PARAM in ${__normalized_params}; do
    ARGS=("${ARGS[@]}" "'$PARAM'")
  done
  IFS="$IFS_ORIG"

  eval $VALUE_REF="'${ARGS[*]}'"

  debug "> [ ${NAME} ... ]: ${!VALUE_REF}"
}

function parse_required_args () {
  local VALUE_REF="$1"
  local NAME=$(key_color "$(lowercase ${VALUE_REF})")
  local VARIABLE_NAME=$(variable_color "\${${VALUE_REF}[@]}")
  local HELP_TEXT="$2"

  local IFS_ORIG="$IFS"
  local ARGS=()

  local VALUE_FOUND=''

  __reactor_args=(
    "${__reactor_args[@]}"
    "$(lowercase "${VALUE_REF}") ..."
  )
  __reactor_arg_help=(
    "${__reactor_arg_help[@]}"
    "    $(printf %-35s "${NAME} ...") [ ${VARIABLE_NAME} ] ${HELP_TEXT} $(alert_color "(REQUIRED)")"
  )

  IFS=$'\n'
  for PARAM in ${__normalized_params}; do
    ARGS=("${ARGS[@]}" "'$PARAM'")
    VALUE_FOUND='1'
  done
  IFS="$IFS_ORIG"

  if [ ! "$VALUE_FOUND" ]; then
    error "Parameters [ ${NAME} ... ] (empty)"

    __reactor_arg_errors='1'
  fi

  eval $VALUE_REF="'${ARGS[*]}'"

  debug "> [<${NAME}> ...]: ${!VALUE_REF}"
}
