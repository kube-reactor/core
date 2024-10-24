#
#=========================================================================================
# Execution Hook Utilities
#
source "${__utilities_dir}/exec.sh"


function load_library () {
  library_type="$1"

  if check_project; then
    for project in $(config docker); do
      project_dir="${__docker_dir}/$(config docker.$project.project $project)"
      library_dir="${project_dir}/reactor/${library_type}"
      if [ -d "$library_dir" ]; then
        for file in "${library_dir}"/*.sh; do
          source "$file"
        done
      fi
    done
    for chart in $(config charts); do
      chart_dir="${__charts_dir}/$(config charts.$chart.project $chart)"
      library_dir="${chart_dir}/reactor/${library_type}"
      if [ -d "$library_dir" ]; then
        for file in "${library_dir}"/*.sh; do
          source "$file"
        done
      fi
    done
    for extension in $(config extensions); do
      extension_dir="${__extension_dir}/${extension}"
      library_dir="${extension_dir}/reactor/${library_type}"
      if [ -d "$library_dir" ]; then
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

function run_hook () {
  hook_name="$1"

  if check_project; then
    # Execute dependency hook if it exists
    for project in $(config docker); do
      project_dir="${__docker_dir}/$(config docker.$project.project $project)"
      hook_function="hook_${project}_${hook_name}"

      if function_exists "$hook_function"; then
        "$hook_function" "$project_dir"
      fi
    done
    for chart in $(config charts); do
      chart_dir="${__charts_dir}/$(config charts.$chart.project $chart)"
      hook_function="hook_${chart}_${hook_name}"

      if function_exists "$hook_function"; then
        "$hook_function" "$chart_dir"
      fi
    done
    for extension in $(config extensions); do
      extension_dir="${__extension_dir}/${extension}"
      hook_function="hook_${extension}_${hook_name}"

      if function_exists "$hook_function"; then
        "$hook_function" "$extension_dir"
      fi
    done
  fi

  # Execute project hook if it exists
  hook_function="hook_${hook_name}"
  if function_exists "$hook_function"; then
    "$hook_function"
  fi
}
