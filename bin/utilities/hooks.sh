#
#=========================================================================================
# Execution Hook Utilities
#

function load_hooks () {
  local hooks_script_name="hooks"

  if check_project; then
    for extension in $(config extensions); do
      extension_dir="${__repo_dir}/$(config extensions.$extension.directory $extension)"
      hook_script="${extension_dir}/reactor/${hooks_script_name}.sh"

      if [ -f "$hook_script" ]; then
        source "$hook_script"
      fi
    done

    hook_script="${__project_reactor_dir}/${hooks_script_name}.sh"
    if [ -f "$hook_script" ]; then
      source "$hook_script"
    fi

  elif [ -d "${__exec_reactor_dir}" ]; then
    hook_script="${__exec_reactor_dir}/${hooks_script_name}.sh"
    if [ -f "$hook_script" ]; then
      source "$hook_script"
    fi
  fi
}

function save_libraries () {
  echo "" >"${__library_file}"

  for type in "${__library_types[@]}"; do
    if [ -d "${__bin_dir}/${type}" ]; then
      for file in "${__bin_dir}/${type}"/*.sh; do
        echo "$file" >>"${__library_file}"
      done
    fi
  done
  if check_project; then
    for extension in $(config extensions); do
      extension_dir="${__repo_dir}/$(config extensions.$extension.directory $extension)"

      for type in "${__library_types[@]}"; do
        library_dir="${extension_dir}/reactor/${type}"

        if [[ -d "$library_dir" ]] \
          && compgen -G "${library_dir}"/*.sh >/dev/null; then
          for file in "${library_dir}"/*.sh; do
            echo "$file" >>"${__library_file}"
          done
        fi
      done
    done

    for type in "${__library_types[@]}"; do
      if compgen -G "${__project_reactor_dir}/${type}"/*.sh >/dev/null; then
        for file in "${__project_reactor_dir}/${type}"/*.sh; do
          echo "$file" >>"${__library_file}"
        done
      fi
    done
  fi
  load_libraries
}

function load_libraries () {
  local missing=0

  if [ -f "${__library_file}" ]; then
    while IFS= read -r file; do
      if [ "$file" ]; then
        if [ -f "$file" ]; then
          source "$file"
        else
          missing=1
          break
        fi
      fi
    done <"${__library_file}"
  fi

  if [ $missing -eq 1 ]; then
    save_libraries

  elif ! check_project && [[ -d "${__exec_reactor_dir}" ]]; then
    for type in "${__library_types[@]}"; do
      if [ -d "${__exec_reactor_dir}/${type}" ]; then
        for file in "${__exec_reactor_dir}/${type}"/*.sh; do
          source "$file"
        done
      fi
    done
  fi
}

function source_hook () {
  hook_name="$1"

  if check_project; then
    for extension in $(config extensions); do
      extension_dir="${__repo_dir}/$(config extensions.$extension.directory $extension)"
      hook_script="${extension_dir}/reactor/${hook_name}.sh"

      if [ -f "$hook_script" ]; then
        source "$hook_script" "$extension" "$extension_dir"
      fi
    done

    # Include project hook if it exists
    if [ -f "${__project_reactor_dir}/${hook_name}.sh" ]; then
      source "${__project_reactor_dir}/${hook_name}.sh"
    fi

  elif [ -d "${__exec_reactor_dir}" ]; then
    if [ -f "${__exec_reactor_dir}/${hook_name}.sh" ]; then
      source "${__exec_reactor_dir}/${hook_name}.sh" "directory" "${__exec_dir}"
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
    for extension in $(config extensions); do
      extension_dir="${__repo_dir}/$(config extensions.$extension.directory $extension)"
      utility_script="${extension_dir}/reactor/utilities/${utility_name}.sh"

      if [ -f "$utility_script" ]; then
        source "$utility_script" "$extension" "$extension_dir"
      fi
    done

    # Include project utility if it exists
    if [ -f "${__project_reactor_dir}/utilities/${utility_name}.sh" ]; then
      source "${__project_reactor_dir}/utilities/${utility_name}.sh"
    fi

  elif [ -d "${__exec_reactor_dir}" ]; then
    if [ -f "${__exec_reactor_dir}/utilities/${utility_name}.sh" ]; then
      source "${__exec_reactor_dir}/utilities/${utility_name}.sh" "directory" "${__exec_dir}"
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
    for extension in $(config extensions); do
      extension_dir="${__repo_dir}/$(config extensions.$extension.directory $extension)"
      run_hook_function "$extension_dir" "$hook_name" "$@"
    done

    run_hook_function "${__project_dir}" "$hook_name" "$@"

  elif [ -d "${__exec_reactor_dir}" ]; then
    run_hook_function "${__exec_dir}" "$hook_name" "$@"
  fi
}
