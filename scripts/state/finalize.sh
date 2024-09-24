#
#=========================================================================================
# Command shutdown
#

# Include dependency finalization if it exists
for project in $(config docker); do
  project_dir="${__docker_dir}/$(config docker.$project.directory $project)"
  finalize_script="${project_dir}/reactor/finalize.sh"
  if [ -f "$finalize_script" ]; then
    source "$finalize_script" "$project" "$project_dir"
  fi
  if function_exists "finalize_${project}"; then
    "finalize_${project}"
  fi
done
for chart in $(config charts); do
  chart_dir="${__charts_dir}/$(config charts.$chart.directory $chart)"
  finalize_script="${chart_dir}/reactor/finalize.sh"
  if [ -f "$finalize_script" ]; then
    source "$finalize_script" "$chart" "$chart_dir"
  fi
  if function_exists "finalize_${chart}"; then
    "finalize_${chart}"
  fi
done
for extension in $(config extensions); do
  extension_dir="${__extension_dir}/${extension}"
  finalize_script="${extension_dir}/reactor/finalize.sh"
  if [ -f "$finalize_script" ]; then
    source "$finalize_script" "$extension" "$extension_dir"
  fi
  if function_exists "finalize_${extension}"; then
    "finalize_${extension}"
  fi
done

# Include project finalization if it exists
if [ -f "${__project_reactor_dir}/finalize.sh" ]; then
  source "${__project_reactor_dir}/finalize.sh"
fi
if function_exists "finalize"; then
  finalize
fi