#
#=========================================================================================
# Command shutdown
#

# Include dependency finalization if it exists
for project in $(config docker); do
  project_dir="${__docker_dir}/${project}"
  finalize_script="${project_dir}/reactor/finalize.sh"
  if [ -x "$finalize_script" ]; then
    "$finalize_script" "$project"
  fi
done
for chart in $(config charts); do
  chart_dir="${__charts_dir}/${chart}"
  finalize_script="${chart_dir}/reactor/finalize.sh"
  if [ -x "$finalize_script" ]; then
    "$finalize_script" "$chart"
  fi
done

# Include project finalization if it exists
if [ -x "${__project_reactor_dir}/finalize.sh" ]; then
  "${__project_reactor_dir}/finalize.sh"
fi