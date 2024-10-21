#
#=========================================================================================
# CLI Utilities
#

export TERMINAL_COLUMNS="$(stty -a | grep -Po '(?<=columns )\d+')"
export TERMINAL_ROWS="$(stty -a | grep -Po '(?<=rows )\d+')"


function check_color () {
  if [[ "$arg_n" ]] || { [[ "${TERM:-}" != "xterm"* ]] && [[ "${TERM:-}" != "screen"* ]]; } || [[ ! -t 2 ]]; then
    return 1
  fi
  return 0
}
function debug_color () {
  local text="${1:-}"
  if check_color; then
    echo -e "${__color_debug}${text}${__color_reset}"
  else
    echo "$text"
  fi
}
function info_color () {
  local text="${1:-}"
  if check_color; then
    echo -e "${__color_info}${text}${__color_reset}"
  else
    echo "$text"
  fi
}
function notice_color () {
  local text="${1:-}"
  if check_color; then
    echo -e "${__color_notice}${text}${__color_reset}"
  else
    echo "$text"
  fi
}
function warning_color () {
  local text="${1:-}"
  if check_color; then
    echo -e "${__color_warning}${text}${__color_reset}"
  else
    echo "$text"
  fi
}
function error_color () {
  local text="${1:-}"
  if check_color; then
    echo -e "${__color_error}${text}${__color_reset}"
  else
    echo "$text"
  fi
}
function critical_color () {
  local text="${1:-}"
  if check_color; then
    echo -e "${__color_critical}${text}${__color_reset}"
  else
    echo "$text"
  fi
}
function alert_color () {
  local text="${1:-}"
  if check_color; then
    echo -e "${__color_alert}${text}${__color_reset}"
  else
    echo "$text"
  fi
}
function emergency_color () {
  local text="${1:-}"
  if check_color; then
    echo -e "${__color_emergency}${text}${__color_reset}"
  else
    echo "$text"
  fi
}
function variable_color () {
  local text="${1:-}"
  if check_color; then
    echo -e "${__color_variable}${text}${__color_reset}"
  else
    echo "$text"
  fi
}
function key_color () {
  local text="${1:-}"
  if check_color; then
    echo -e "${__color_key}${text}${__color_reset}"
  else
    echo "$text"
  fi
}
function value_color () {
  local text="${1:-}"
  if check_color; then
    echo -e "${__color_value}${text}${__color_reset}"
  else
    echo "$text"
  fi
}

function function_exists () {
  declare -F "$1" > /dev/null;
}

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

  if [ $REACTOR_LOCAL -ne 0 ]; then
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

function emergency () {                               __log emergency "${@}"; exit 1; }
function alert ()     { [[ "${LOG_LEVEL:-0}" -ge 1 ]] && __log alert "${@}"; true; }
function critical ()  { [[ "${LOG_LEVEL:-0}" -ge 2 ]] && __log critical "${@}"; true; }
function error ()     { [[ "${LOG_LEVEL:-0}" -ge 3 ]] && __log error "${@}"; true; }
function warning ()   { [[ "${LOG_LEVEL:-0}" -ge 4 ]] && __log warning "${@}"; true; }
function notice ()    { [[ "${LOG_LEVEL:-0}" -ge 5 ]] && __log notice "${@}"; true; }
function info ()      { [[ "${LOG_LEVEL:-0}" -ge 6 ]] && __log info "${@}"; true; }
function debug ()     { [[ "${LOG_LEVEL:-0}" -ge 7 ]] && __log debug "${@}"; true; }

function confirm () {
  read -p "This is a destructive operation! Type YES to continue?: " CONFIRM_INPUT
  [[ $CONFIRM_INPUT =~ ^[Yy][Ee][Ss]$ ]] || exit 1
}


function check_admin () {
  sudo -v
}


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

function lowercase () {
  render "$1" | tr '[:upper:]' '[:lower:]'
}