#
#=========================================================================================
# CLI Utilities
#
load_utilities disk


if tty -s; then
  TERMINAL_COLUMNS="$(stty -a | grep -Po '(?<=columns )\d+')"
  TERMINAL_ROWS="$(stty -a | grep -Po '(?<=rows )\d+')"
else
  TERMINAL_COLUMNS="50"
  TERMINAL_ROWS="50"
fi
export TERMINAL_COLUMNS
export TERMINAL_ROWS

export COLOR_DEBUG="${COLOR_DEBUG:-"\\x1b[1;35m"}"
export COLOR_INFO="${COLOR_INFO:-"\\x1b[1;32m"}"
export COLOR_NOTICE="${COLOR_NOTICE:-"\\x1b[1;34m"}"
export COLOR_WARNING="${COLOR_WARNING:-"\\x1b[1;33m"}"
export COLOR_ERROR="${COLOR_ERROR:-"\\x1b[1;31m"}"
export COLOR_CRITICAL="${COLOR_CRITICAL:-"\\x1b[1;31m"}"
export COLOR_ALERT="${COLOR_ALERT:-"\\x1b[1;37;41m"}"
export COLOR_EMERGENCY="${COLOR_EMERGENCY:-"\\x1b[1;4;5;37;41m"}"
export COLOR_VARIABLE="${COLOR_VARIABLE:-"\\x1b[1;32m"}"
export COLOR_KEY="${COLOR_KEY:-"\\x1b[1;33m"}"
export COLOR_VALUE="${COLOR_VALUE:-"\\x1b[1;34m"}"
export COLOR_TERMINAL="${COLOR_TERMINAL:-"\\x1b[1;32;40m"}"
export COLOR_RESET="\\x1b[0m"

#
#=========================================================================================
# Color Utilities
#

function check_color () {
  if ! is_initialized || [[ "${arg_n:-}" ]] || [[ ! -t 2 ]]; then
    return 1
  fi
  return 0
}
function debug_color () {
  local text="${1:-}"
  if check_color; then
    echo -e "${COLOR_DEBUG}${text}${COLOR_RESET}"
  else
    echo "$text"
  fi
}
function info_color () {
  local text="${1:-}"
  if check_color; then
    echo -e "${COLOR_INFO}${text}${COLOR_RESET}"
  else
    echo "$text"
  fi
}
function notice_color () {
  local text="${1:-}"
  if check_color; then
    echo -e "${COLOR_NOTICE}${text}${COLOR_RESET}"
  else
    echo "$text"
  fi
}
function warning_color () {
  local text="${1:-}"
  if check_color; then
    echo -e "${COLOR_WARNING}${text}${COLOR_RESET}"
  else
    echo "$text"
  fi
}
function error_color () {
  local text="${1:-}"
  if check_color; then
    echo -e "${COLOR_ERROR}${text}${COLOR_RESET}"
  else
    echo "$text"
  fi
}
function critical_color () {
  local text="${1:-}"
  if check_color; then
    echo -e "${COLOR_CRITICAL}${text}${COLOR_RESET}"
  else
    echo "$text"
  fi
}
function alert_color () {
  local text="${1:-}"
  if check_color; then
    echo -e "${COLOR_ALERT}${text}${COLOR_RESET}"
  else
    echo "$text"
  fi
}
function emergency_color () {
  local text="${1:-}"
  if check_color; then
    echo -e "${COLOR_EMERGENCY}${text}${COLOR_RESET}"
  else
    echo "$text"
  fi
}
function variable_color () {
  local text="${1:-}"
  if check_color; then
    echo -e "${COLOR_VARIABLE}${text}${COLOR_RESET}"
  else
    echo "$text"
  fi
}
function key_color () {
  local text="${1:-}"
  if check_color; then
    echo -e "${COLOR_KEY}${text}${COLOR_RESET}"
  else
    echo "$text"
  fi
}
function value_color () {
  local text="${1:-}"
  if check_color; then
    echo -e "${COLOR_VALUE}${text}${COLOR_RESET}"
  else
    echo "$text"
  fi
}
function terminal_color () {
  local text="${1:-}"
  if check_color; then
    echo -e "${COLOR_TERMINAL}${text}${COLOR_RESET}"
  else
    echo "$text"
  fi
}

#
#=========================================================================================
# Logging Utilities
#

# requires `set -o errtrace`
function __err_report() {
    local error_code=${?}
    error "Error in kubectl reactor in function ${1} on line ${2}: ${error_code}"
    exit ${error_code}
}

function __log () {
  local log_level="${1}"
  shift

  local color_function="${log_level}_color"

  # all remaining arguments are to be printed
  local log_line=""
  local date_time="$(date -u +"%Y-%m-%d %H:%M:%S UTC")"

  if [ ${REACTOR_LOCAL:-0} -ne 0 ]; then
    local local_indicator="*"
  else
    local local_indicator=""
  fi

  while IFS=$'\n' read -r log_line; do
    local log_info="$($color_function "$(printf "[%s]%s" "${log_level}" "${local_indicator}")")"

    echo -e "${date_time} ${log_info} ${log_line}" 1>&2
    echo "${date_time} [${log_level}] ${log_line}" >>"$(logfile)"
  done <<< "${@:-}"
}

function emergency () { __log emergency "${@}"; exit 1; }
function alert ()     { [[ "${LOG_LEVEL:-0}" -ge 1 ]] && __log alert "${@}"; true; }
function critical ()  { [[ "${LOG_LEVEL:-0}" -ge 2 ]] && __log critical "${@}"; true; }
function error ()     { [[ "${LOG_LEVEL:-0}" -ge 3 ]] && __log error "${@}"; true; }
function warning ()   { [[ "${LOG_LEVEL:-0}" -ge 4 ]] && __log warning "${@}"; true; }
function notice ()    { [[ "${LOG_LEVEL:-0}" -ge 5 ]] && __log notice "${@}"; true; }
function info ()      { [[ "${LOG_LEVEL:-0}" -ge 6 ]] && __log info "${@}"; true; }
function debug ()     { [[ "${LOG_LEVEL:-0}" -ge 7 ]] && __log debug "${@}"; true; }

#
#=========================================================================================
# Prompting Utilities
#

function confirm () {
  read -p "This is a destructive operation! Type YES to continue?: " CONFIRM_INPUT
  [[ $CONFIRM_INPUT =~ ^[Yy][Ee][Ss]$ ]] || exit 1
}

#
#=========================================================================================
# Administrative Utilities
#

function check_admin () {
  sudo -v
}

#
#=========================================================================================
# Display Rendering Utilities
#

function render () {
  echo "$1"
}

function add_space () {
  render ""
}

function add_line () {
  local char="$1"
  for ((i=1; i<=$TERMINAL_COLUMNS; i++)); do echo -n "$char"; done
}

function format_width () {
  local text="$1"
  local indent="${2:-0}"
  render "$(echo "$text" | fold -s -w $TERMINAL_COLUMNS | sed "2,\$s/^/$(printf ' %.0s' $(seq 1 $indent))/")"
}

#
#=========================================================================================
# Text Conversion Utilities
#

function lowercase () {
  render "$1" | tr '[:upper:]' '[:lower:]'
}
