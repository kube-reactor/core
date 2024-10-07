#
#=========================================================================================
# Project bootstrap functions
#

function project_file () {
  project_file="${1}/reactor.yml"

  if [ -f "$project_file" ]; then
    echo "$project_file"
    return
  fi

  parent_dir="$(dirname $1)"

  if [ "$parent_dir" = "/" ]; then
    echo ""
  else
    project_file "$parent_dir"
  fi
}

function config () {
  "${__script_dir}/utilities/locator.py" "$1" "${2-}"
}

function env_json () {
  "${__script_dir}/utilities/env_json.py"
}

function function_exists () {
  declare -F "$1" > /dev/null;
}
