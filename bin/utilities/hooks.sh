#
#=========================================================================================
# Execution Hook Utilities
#

function load_hooks () {
  local hooks_script_name="hooks"

  if check_project; then
    if [ "${__environment}" == "local" ]; then
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
    fi
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

function save_libraries () {
  local library_types=("utilities" "commands")

  echo "" >"${__library_file}"

  for type in "${library_types[@]}"; do
    if [ -d "${__bin_dir}/${type}" ]; then
      for file in "${__bin_dir}/${type}"/*.sh; do
        echo "$file" >>"${__library_file}"
      done
    fi
  done
  if check_project; then
    if [ "${__environment}" == "local" ]; then
      for project in $(config docker); do
        project_dir="${__docker_dir}/$(config docker.$project.project $project)"

        for type in "${library_types[@]}"; do
          library_dir="${project_dir}/reactor/${type}"

          if [[ -d "$library_dir" ]] \
            && compgen -G "${library_dir}"/*.sh >/dev/null; then
            for file in "${library_dir}"/*.sh; do
              echo "$file" >>"${__library_file}"
            done
          fi
        done
      done
      for chart in $(config charts); do
        chart_dir="${__charts_dir}/$(config charts.$chart.project $chart)"

        for type in "${library_types[@]}"; do
          library_dir="${chart_dir}/reactor/${type}"

          if [[ -d "$library_dir" ]] \
            && compgen -G "${library_dir}"/*.sh >/dev/null; then
            for file in "${library_dir}"/*.sh; do
              echo "$file" >>"${__library_file}"
            done
          fi
        done
      done
    fi
    for extension in $(config extensions); do
      extension_dir="${__extension_dir}/${extension}"

      for type in "${library_types[@]}"; do
        library_dir="${extension_dir}/reactor/${type}"

        if [[ -d "$library_dir" ]] \
          && compgen -G "${library_dir}"/*.sh >/dev/null; then
          for file in "${library_dir}"/*.sh; do
            echo "$file" >>"${__library_file}"
          done
        fi
      done
    done
    for type in "${library_types[@]}"; do
      if compgen -G "${__project_reactor_dir}/${type}"/*.sh >/dev/null; then
        for file in "${__project_reactor_dir}/${type}"/*.sh; do
          echo "$file" >>"${__library_file}"
        done
      fi
    done
  fi
}

function load_libraries () {
  if [ -f "${__library_file}" ]; then
    while IFS= read -r file; do
      if [ "$file" ]; then
        source "$file"
      fi
    done <"${__library_file}"
  fi
}

function source_hook () {
  hook_name="$1"

  if check_project; then
    if [ "${__environment}" == "local" ]; then
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
    fi
    for extension in $(config extensions); do
      extension_dir="${__extension_dir}/${extension}"
      hook_script="${extension_dir}/reactor/${hook_name}.sh"
      if [ -f "$hook_script" ]; then
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
    if [ "${__environment}" == "local" ]; then
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
    fi
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
    if [ "${__environment}" == "local" ]; then
      for docker in $(config docker); do
        docker_dir="${__docker_dir}/$(config docker.docker.project $docker)"
        run_hook_function "$docker_dir" "$hook_name" "$@"
      done
      for chart in $(config charts); do
        chart_dir="${__charts_dir}/$(config charts.$chart.project $chart)"
        run_hook_function "$chart_dir" "$hook_name" "$@"
      done
    fi
    for extension in $(config extensions); do
      extension_dir="${__extension_dir}/${extension}"
      run_hook_function "$extension_dir" "$hook_name" "$@"
    done
    run_hook_function "${__project_dir}" "$hook_name" "$@"
  fi
}
