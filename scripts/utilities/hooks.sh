#
#=========================================================================================
# Execution Hook Utilities
#

function load_library () {
  library_type="$1"

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
}

function source_hook () {
  hook_name="$1"

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
}

function exec_hook () {
  hook_name="$1"

  # Execute dependency hook if it exists
  for project in $(config docker); do
    project_dir="${__docker_dir}/$(config docker.$project.project $project)"
    if function_exists "${project}_${hook_name}"; then
      "${project}_${hook_name}" "$project_dir"
    fi
  done
  for chart in $(config charts); do
    chart_dir="${__charts_dir}/$(config charts.$chart.project $chart)"
    if function_exists "${chart}_${hook_name}"; then
      "${chart}_${hook_name}" "$chart_dir"
    fi
  done
  for extension in $(config extensions); do
    extension_dir="${__extension_dir}/${extension}"
    if function_exists "${extension}_${hook_name}"; then
      "${extension}_${hook_name}" "$extension_dir"
    fi
  done

  # Execute project hook if it exists
  if function_exists "$hook_name"; then
    "$hook_name"
  fi
}
