#
#=========================================================================================
# Command Argument Utilities
#

function reactor_args () {
  export __app_args=("$@")
  export __normalized_params="$(normalize_params "$@")"
  export __reactor_flags=()
  export __reactor_options=()
  export __reactor_args=()
  export __reactor_arg_help=()
  export __reactor_arg_errors=""

  parse_flag '-h|--help' arg_h "Display help message"
  parse_flag --verbose arg_v "Enable verbose mode, print script as it is executed"
  parse_flag --debug arg_d "Enables debug mode"
  parse_flag --no-color arg_n "Disable color output"

  export arg_h
  export arg_v
  export arg_d
  export arg_n

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

  # No color mode
  if [ "$arg_n" ]; then
    export NO_COLOR="true"
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
  debug "> Color: ${NO_COLOR:-}"
  debug "> Help: ${arg_h}"
  debug ""

  debug "Script properties"
  debug "======================================"
  debug "> Local execution: ${REACTOR_LOCAL}"
  debug "> OS type: ${OSTYPE}"
  debug "> OS name: ${__os}"
  debug "> CPU arch: ${__architecture}"
  debug "> Invocation: ${__reactor_invocation}"
  debug "> Reactor directory: ${__reactor_dir}"
  debug "> Script directory: ${__script_dir}"
  debug ""

  debug "Project and development properties"
  debug "======================================"
  debug "> Project directory: ${__project_dir}"
  debug "> Project manifest: ${__project_file}"
  debug "> Certificate directory: ${__certs_dir}"
  debug "> Executable directory: ${__binary_dir}"
  debug "> Docker image project root directory: ${__docker_dir}"
  debug "> Helm chart project root directory: ${__charts_dir}"
  debug "> Terraform project root directory: ${__terraform_dir}"
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

function parse_flag () {
  local FLAGS="$1"
  local FOUND_REF="$2"
  local HELP_TEXT="$3"

  local LOCAL_FOUND=''

  local ALT_PARAMS=''
  local IFS_ORIG="$IFS"

  eval $FOUND_REF=''

  IFS='|'

  __reactor_flags=(
    "${__reactor_flags[@]}"
    "    $(printf %-30s ${FLAGS//|/ }) ${HELP_TEXT}"
  )
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

  __normalized_params=$ALT_PARAMS
  IFS="$IFS_ORIG"

  debug "> ${FLAGS//|/ }: ${!FOUND_REF}"
}

function parse_option () {
  local OPTIONS="$1"
  local VALUE_REF="$2"
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
    "    $(printf %-30s "${OPTIONS//|/ } <value>") ${HELP_TEXT} (${VALUE_DEFAULT})"
  )
  read -ra OPTION_ARRAY <<< "$OPTIONS"

  IFS=$'\n'
  for PARAM in ${__normalized_params}; do
    if [ "$NEEDS_PROCESSING" ]; then
      if [[ $PARAM =~ ^- ]]; then
        ERROR_MSG=`echo "Parameter [ $OPTIONS ] (empty): $ERROR_MSG"`
        error "$ERROR_MSG"

        IFS="$IFS_ORIG"
        __reactor_arg_errors="1"
      fi

      if [[ ! "$arg_h" ]] && [[ "$VALIDATOR" ]]; then
        if ! $VALIDATOR "$PARAM"; then
          ERROR_MSG=`echo "Parameter [ $OPTIONS ] ($PARAM): $ERROR_MSG"`
          error "$ERROR_MSG"
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
    ERROR_MSG=`echo "Parameter [ $OPTIONS ] (empty): $ERROR_MSG"`
    error "$ERROR_MSG"

    IFS="$IFS_ORIG"
    __reactor_arg_errors="1"
  fi

  __normalized_params=$ALT_PARAMS
  IFS="$IFS_ORIG"

  debug "> ${OPTIONS//|/ }: ${!VALUE_REF}"
}

function parse_arg () {
  local NAME="$1"
  local VALUE_REF="$2"
  local HELP_TEXT="$3"
  local VALIDATOR="${4:-"validate_string"}"
  local ERROR_MSG="${5:-"Argument ${NAME} ${VALIDATOR} failed"}"

  local ALT_PARAMS=''
  local IFS_ORIG="$IFS"

  local VALUE_FOUND=''

  eval $VALUE_REF=""

  __reactor_args=(
    "${__reactor_args[@]}"
    "<${NAME}>"
  )
  __reactor_arg_help=(
    "${__reactor_arg_help[@]}"
    "    $(printf %-30s "${NAME}") ${HELP_TEXT} (REQUIRED)"
  )

  IFS=$'\n'
  for PARAM in ${__normalized_params}; do
    if [[ $PARAM =~ ^[^-] ]] && [[ ! "$VALUE_FOUND" ]]; then
      if [[ ! "$arg_h" ]] && [[ "$VALIDATOR" ]]; then
        if ! $VALIDATOR "$PARAM"; then
          ERROR_MSG=`echo "Parameter [ $NAME ] ($PARAM): $ERROR_MSG"`
          error "$ERROR_MSG"
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
    ERROR_MSG=`echo "Parameter [ $NAME ] (empty): $ERROR_MSG"`
    error "$ERROR_MSG"

    IFS="$IFS_ORIG"
    __reactor_arg_errors="1"
  fi

  __normalized_params=$ALT_PARAMS
  IFS="$IFS_ORIG"

  debug "> ${NAME}: ${!VALUE_REF}"
}
