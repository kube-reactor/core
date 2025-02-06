#
#=========================================================================================
# Execution Hook Utilities
#

function load_hooks () {
  local hooks_script_name="hooks"

  if check_project; then
    for project in $(config docker); do
      project_dir="${__docker_dir}/$(config docker.$project.project $project)"
      hook_script="${project_dir}/reactor/${hooks_script_name}.sh"
      if [ -f "$hook_script" ]; then
        source "$hook_script"
      fi
    done
    for chart in $(config charts); do
      chart_dir="${__charts_dir}/$(config charts.$chart.project $chart)"
      hook_script="${chart_dir}/reactor/${hooks_script_name}.sh"
      if [ -f "$hook_script" ]; then
        source "$hook_script"
      fi
    done
    for extension in $(config extensions); do
      extension_dir="${__extension_dir}/${extension}"
      hook_script="${extension_dir}/reactor/${hooks_script_name}.sh"
      if [ -f "$hook_script" ]; then
        source "$hook_script"
      fi
    done
    hook_script="${__project_reactor_dir}/${hooks_script_name}.sh"
    if [ -f "$hook_script" ]; then
      source "$hook_script"
    fi
  fi
}

function load_library () {
  local library_type="$1"
  local library_core_dir="${__bin_dir}/${library_type}"

  if [ -d "$library_core_dir" ]; then
    for file in "${library_core_dir}"/*.sh; do
      source "$file"
    done
  fi
  if check_project; then
    for project in $(config docker); do
      project_dir="${__docker_dir}/$(config docker.$project.project $project)"
      library_dir="${project_dir}/reactor/${library_type}"

      if [[ -d "$library_dir" ]] \
        && compgen -G "${library_dir}"/*.sh >/dev/null; then
        for file in "${library_dir}"/*.sh; do
          source "$file"
        done
      fi
    done
    for chart in $(config charts); do
      chart_dir="${__charts_dir}/$(config charts.$chart.project $chart)"
      library_dir="${chart_dir}/reactor/${library_type}"

      if [[ -d "$library_dir" ]] \
        && compgen -G "${library_dir}"/*.sh >/dev/null; then
        for file in "${library_dir}"/*.sh; do
          source "$file"
        done
      fi
    done
    for extension in $(config extensions); do
      extension_dir="${__extension_dir}/${extension}"
      library_dir="${extension_dir}/reactor/${library_type}"

      if [[ -d "$library_dir" ]] \
        && compgen -G "${library_dir}"/*.sh >/dev/null; then
        for file in "${library_dir}"/*.sh; do
          source "$file"
        done
      fi
    done
    if compgen -G "${__project_reactor_dir}/${library_type}"/*.sh >/dev/null; then
      for file in "${__project_reactor_dir}/${library_type}"/*.sh; do
        source "$file"
      done
    fi
  fi
}

function source_hook () {
  hook_name="$1"

  if check_project; then
    # Include dependency hook if it exists
    for project in $(config docker); do
      project_dir="${__docker_dir}/$(config docker.$project.project $project)"
      hook_script="${project_dir}/reactor/${hook_name}.sh"
      if [ -f "$hook_script" ]; then
        source "$hook_script" "$project" "$project_dir"
      fi
      hook_script="${__project_reactor_dir}/docker/${project}_${hook_name}.sh"
      if [ -f "$hook_script" ]; then
        source "$hook_script" "$project" "$project_dir"
      fi
    done
    for chart in $(config charts); do
      chart_dir="${__charts_dir}/$(config charts.$chart.project $chart)"
      hook_script="${chart_dir}/reactor/${hook_name}.sh"
      if [ -f "$hook_script" ]; then
        source "$hook_script" "$chart" "$chart_dir"
      fi
      hook_script="${__project_reactor_dir}/charts/${chart}_${hook_name}.sh"
      if [ -f "$hook_script" ]; then
        source "$hook_script" "$project" "$chart_dir"
      fi
    done
    for extension in $(config extensions); do
      extension_dir="${__extension_dir}/${extension}"
      echo "$extension_dir"
      ls -al "${__project_dir}"
      ls -al "${__extension_dir}"
      echo "-----"
      hook_script="${extension_dir}/reactor/${hook_name}.sh"
      echo "$hook_script"
      if [ -f "$hook_script" ]; then
        echo "sourcing: $extension $extension_dir"
        source "$hook_script" "$extension" "$extension_dir"
      fi
    done
    # Include project hook if it exists
    if [ -f "${__project_reactor_dir}/${hook_name}.sh" ]; then
      source "${__project_reactor_dir}/${hook_name}.sh"
    fi
  fi
}

function source_utility () {
  local utility_name="$1"
  local core_utility_script="${__utilities_dir}/${utility_name}.sh"

  if [ -f "$core_utility_script" ]; then
    source "$core_utility_script"
  fi
  if check_project; then
    # Include dependency utility if it exists
    for project in $(config docker); do
      project_dir="${__docker_dir}/$(config docker.$project.project $project)"
      utility_script="${project_dir}/reactor/utilities/${utility_name}.sh"
      if [ -f "$utility_script" ]; then
        source "$utility_script" "$project" "$project_dir"
      fi
    done
    for chart in $(config charts); do
      chart_dir="${__charts_dir}/$(config charts.$chart.project $chart)"
      utility_script="${chart_dir}/reactor/utilities/${utility_name}.sh"
      if [ -f "$utility_script" ]; then
        source "$utility_script" "$chart" "$chart_dir"
      fi
    done
    for extension in $(config extensions); do
      extension_dir="${__extension_dir}/${extension}"
      utility_script="${extension_dir}/reactor/utilities/${utility_name}.sh"
      if [ -f "$utility_script" ]; then
        source "$utility_script" "$extension" "$extension_dir"
      fi
    done
    # Include project utility if it exists
    if [ -f "${__project_reactor_dir}/utilities/${utility_name}.sh" ]; then
      source "${__project_reactor_dir}/utilities/${utility_name}.sh"
    fi
  fi
}


function load_project_hooks () {
  local project_dir="$1"
  local reactor_dir="${project_dir}/reactor"
  local reactor_hook_dir="${reactor_dir}/hooks"

  if [ -d "$reactor_dir" ]; then
    if [ -f "${reactor_dir}/hooks.sh" ]; then
      source "${reactor_dir}/hooks.sh"
    fi
    if [[ -d "$reactor_hook_dir" ]] \
      && compgen -G "$reactor_hook_dir"/*.sh >/dev/null; then
      for file in "${reactor_hook_dir}"/*.sh; do
        source "$file"
      done
    fi
  fi
}

function run_hook_function () {
  local project_dir="$1"
  local hook_name="hook_${2}"
  shift; shift

  if [ -d "$project_dir" ]; then
    unset -f "$hook_name"

    load_project_hooks "$project_dir"

    if function_exists "$hook_name"; then
      "$hook_name" "$@"
    else
      debug "Hook function (${hook_name}) does not exist in ${project_dir}"
    fi
  fi
}

function run_hook () {
  hook_name="$1"
  shift

  debug "Running hook: ${hook_name} ${@}"

  if check_project; then
    for docker in $(config docker); do
      docker_dir="${__docker_dir}/$(config docker.docker.project $docker)"
      run_hook_function "$docker_dir" "$hook_name" "$@"
    done
    for chart in $(config charts); do
      chart_dir="${__charts_dir}/$(config charts.$chart.project $chart)"
      run_hook_function "$chart_dir" "$hook_name" "$@"
    done
    for extension in $(config extensions); do
      extension_dir="${__extension_dir}/${extension}"
      run_hook_function "$extension_dir" "$hook_name" "$@"
    done
    run_hook_function "${__project_dir}" "$hook_name" "$@"
  fi
}
