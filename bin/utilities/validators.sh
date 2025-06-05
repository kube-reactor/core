
function validate_string () {
  if [ ! "$1" ]; then
    return 1
  else
    return 0
  fi
}

function validate_file () {
  if [[ ! "$1" ]] || [[ ! -f "$1" ]]; then
    return 1
  else
    return 0
  fi
}

function validate_directory () {
  if [[ ! "$1" ]] || [[ ! -d "$1" ]]; then
    return 1
  else
    return 0
  fi
}

function validate_integer () {
  if [[ "$variable" =~ ^\-?[0-9]+$ ]]; then
    return 0
  else
    return 1
  fi
}

function validate_positive_integer () {
  if [[ "$variable" =~ ^[0-9]+$ ]]; then
    return 0
  else
    return 1
  fi
}
