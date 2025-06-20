#!/usr/bin/env bash
#
# Usage:
#
#  "${__bin_dir}/core/test.sh" [flags] <command> [args] [flags/options]
#
#=========================================================================================
# Initialization
#
#
# Development Modes
#
#  * Core Development
#
#    -> When File Exists: ./reactor.template.yaml
#
#    *> git clone https://github.com/kube-reactor/core.git {core_directory}
#    *> cd {core_directory}
#    *> reactor test --name {project_name} --url {(template|project)_url} # ./projects/{project_name} ./templates/{project_name}
#
#  * Template Development
#
#    -> When File Exists: ./cookiecutter.json
#
#    *> git clone {template_git_url} {template_directory}
#    *> cd {template_directory}
#    *> reactor test --name {project_name} # ./{project_name}
#
#  * Project Development
#
#    -> When File Exists: ./reactor.yml
#
#    *> git clone {project_git_url} {project_directory}
#    *> cd {project_directory}
#    *> reactor test # ./
#

# Test project parameters:
#
# 0. None if within project
# 1. {project_name} if within template
# 2. {project_name} and {project_url} if within core

# Development Mode priority:
#
# * project - Use current project
# * template - Use or create new project from existing template (project name)
# * core - Use or create new template and project from template url (project name)
#

# Initialize top level directories and load bootstrap functions
SCRIPT_PATH="${BASH_SOURCE[0]}"

export __script_name="reactor test"
export __core_dir="$(cd "$(dirname "${SCRIPT_PATH}")" && pwd)"
export __bin_dir="$(dirname "${__core_dir}")"
export __app_args=("$@")

export REACTOR_SHELL_OUTPUT="true"

source "${__core_dir}/loader.sh"

#=========================================================================================
# Parameter processing
#
HELP="Test a complete project lifecycle"

function test_params () {
  force_option

  if ! check_project; then
    parse_option --name \
      PROJECT_NAME \
      "Test project name (environment variable: REACTOR_PROJECT_NAME)" \
      "${__project_name}"

    if ! check_template; then
      parse_option --url \
        PROJECT_URL \
        "Project template Git remote URL" \
        "$DEFAULT_PROJECT_URL"

      parse_option --remote \
        PROJECT_REMOTE \
        "Test project Git remote name to fetch (when repository exists)" \
        "$DEFAULT_PROJECT_REMOTE"

      parse_option --reference \
        PROJECT_REFERENCE \
        "Project template Git reference" \
        "$DEFAULT_PROJECT_REFERENCE"
    fi
  else
    export PROJECT_NAME="${__project_name}"
  fi

  parse_option --env \
    PROJECT_ENVIRONMENT \
    "Project environment selector" \
    "${__environment}"

  export REACTOR_ENVIRONMENT="$PROJECT_ENVIRONMENT"

  parse_option --phases \
    PROJECT_PHASES \
    "Comma separated list of test project phases to test of options: startup, running, shutdown, and exit"

  if [ "$PROJECT_PHASES" ]; then
    IFS=',' read -r -a PROJECT_PHASES <<< "$PROJECT_PHASES"
  else
    PROJECT_PHASES=(startup running shutdown exit)
  fi
  export PROJECT_PHASES

  parse_option --tags \
    USER_TEST_TAGS \
    "Comma separated list of test tags to run"

  if [ "$USER_TEST_TAGS" ]; then
    IFS=',' read -r -a USER_TEST_TAGS <<< "$USER_TEST_TAGS"
  else
    USER_TEST_TAGS=()
  fi
  export USER_TEST_TAGS

  parse_flag --running \
    ENSURE_RUNNING \
    "Create new or use an existing cluster for testing purposes"

  parse_flag --no-up \
    NO_UP \
    "Skip running reactor up before running and later phases"

  parse_flag --no-down \
    NO_DOWN \
    "Skip running reactor down, destroy, and clean after running and previous phases"

  parse_flag --no-wait \
    TEST_NO_WAIT \
    "Disable verification retries (useful for debugging)"

  parse_flag --clean \
    CLEAN_PROJECT \
    "Ensure project is shutdown and completely cleaned before beginning tests"
}
parse_cli test_params "$@"

if ! check_project && ! check_template && ! check_core; then
  emergency "To execute test command you must be in either core, template, or project development modes."
fi

debug "Test directory: ${__test_dir}"
debug "Reactor directory: ${__reactor_dir}"
debug "Script directory: ${__bin_dir}"
debug "Projects directory: ${__projects_dir}"
debug "Project name: ${PROJECT_NAME}"
debug "Project environment: ${REACTOR_ENVIRONMENT}"
debug "Project phases: ${PROJECT_PHASES[@]}"
debug "User test tags: ${USER_TEST_TAGS[@]}"

render "Reactor testing requires sudo access to run host commands"
add_space
render " -> this includes commands for: tunneling and local DNS"
add_space
check_admin

if [[ "$CLEAN_PROJECT" ]] && [[ ! "$FORCE" ]]; then
  render "The --clean option will completely destroy and cleanup all project files before testing"
  confirm
fi

export PATH="${__bin_dir}:${PATH}"

#=========================================================================================
# Project testing
#

# [core]> reactor test --name={name} --url={url} --reference=main ...
# [template]> reactor test --name={name} ...
# [project]> reactor test ...

# Test Phases
#
# 1. Project Setup *
# 2. <startup>
# 3. Cluster Startup / Build *
# 4. <running>
# 5. Cluster Shutdown *
# 6. <shutdown>
# 7. Project Cleanup *
# 8. <exit>
#
# * project - No create
# * template - Create {template dir}/{name}
# * core - Create {core dir}/projects/{name}
#
if ! check_project; then
  if check_template; then
    reactor create "$PROJECT_NAME" --ignore --defaults
    cd "${__template_dir}/${PROJECT_NAME}"

  elif check_core; then
    reactor create "$PROJECT_NAME" --ignore --defaults \
      --url="$PROJECT_URL" \
      --remote="$PROJECT_REMOTE" \
      --reference="$PROJECT_REFERENCE"

    cd "${__projects_dir}/${PROJECT_NAME}"
  else
    emergency "You must run tests within a project, template, or core development context"
  fi
else
  cd "${__project_dir}"
fi

debug "Project directory: $(pwd)"
add_space
render " * Sourcing development environment"
source reactor
delete_container_environment

if [ "$arg_d" ]; then
  render_environment
fi
if [ "$CLEAN_PROJECT" ]; then
  reactor clean --force
fi

#
# Project test initialization
#
if [ ! "$ENSURE_RUNNING" ]; then
  if [[ " ${PROJECT_PHASES[*]} " =~ [[:space:]]startup[[:space:]] ]]; then
    start_test phase
    test_phase startup
    verify_test
  fi
fi

#=========================================================================================
# Development Session
#
#
# Starting Up
#
if [ ! "$NO_UP" ]; then
  if [[ "$arg_d" ]] || [[ "$arg_v" ]]; then
    add_space
    render "==========================================================================="
    render "+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++"
    render "+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++"
    render "+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++"
    render "==========================================================================="
  fi
  render " * Running Reactor startup"
  if [[ "$arg_d" ]] || [[ "$arg_v" ]]; then
    add_space
  fi

  function test_up () {
    run_reactor up

    provisioner_environment

    function verify_argocd_domain () {
      verify_host "$ARGOCD_DOMAIN"
    }
    wait verify_argocd_domain 30

    verify_dir "${__project_dir}/cache"
    verify_dir "${__project_dir}/certs"
    verify_dir "${__project_dir}/projects"
    verify_dir "${__project_dir}/.minikube"
    verify_dir "${__env_dir}/.terraform"
    verify_file "${__env_dir}/.kubeconfig"
    verify_file "${__log_dir}/hosts.txt"
    verify_file "${__log_dir}/tunnel.kpid"
    verify_file "${PROVISIONER_GATEWAY}/.terraform.lock.hcl"
    verify_file "${PROVISIONER_GATEWAY}/terraform.tfstate"
  }

  start_test lifecycle start build
  run_test test_up
  verify_test
fi

if [[ " ${PROJECT_PHASES[*]} " =~ [[:space:]]running[[:space:]] ]]; then
  start_test phase
  test_phase running
  verify_test
fi

#
# Shutting Down
#
if [[ ! "$NO_DOWN" ]] && [[ ! "$ENSURE_RUNNING" ]]; then
  if [[ "$arg_d" ]] || [[ "$arg_v" ]]; then
    add_space
    render "==========================================================================="
    render "+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++"
    render "+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++"
    render "+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++"
    render "==========================================================================="
  fi
  render " * Running Reactor shutdown"
  if [[ "$arg_d" ]] || [[ "$arg_v" ]]; then
    add_space
  fi

  function test_down () {
    run_reactor down

    function verify_argocd_domain () {
      verify_no_host "$ARGOCD_DOMAIN"
    }
    wait verify_argocd_domain 30

    verify_no_file "${__log_dir}/tunnel.kpid"
    verify_no_file "${__log_dir}/dashboard.kpid"
    verify_no_file "${__log_dir}/hosts.txt"
    verify_no_file "${__env_dir}/.kubeconfig"
  }

  start_test lifecycle clean
  run_test test_down
  verify_test

  if [[ " ${PROJECT_PHASES[*]} " =~ [[:space:]]shutdown[[:space:]] ]]; then
    start_test phase clean
    test_phase shutdown
    verify_test
  fi
fi

#
# Cleaning Up
#
if [[ ! "$NO_DOWN" ]] && [[ ! "$ENSURE_RUNNING" ]]; then
  if [[ "$arg_d" ]] || [[ "$arg_v" ]]; then
    add_space
    render "==========================================================================="
    render "+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++"
    render "+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++"
    render "+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++"
    render "==========================================================================="
  fi
  render " * Running Reactor cleanup"
  if [[ "$arg_d" ]] || [[ "$arg_v" ]]; then
    add_space
  fi

  function test_destroy () {
    run_reactor destroy --force

    provisioner_environment

    verify_no_dir "${__project_dir}/.minikube"
    verify_no_dir "${__env_dir}/.terraform"
    verify_no_file "${PROVISIONER_GATEWAY}/.terraform.lock.hcl"
    verify_no_file "${PROVISIONER_GATEWAY}/terraform.tfstate"
  }

  function test_clean () {
    run_reactor clean --force

    verify_no_dir "${__project_dir}/cache"
    verify_no_dir "${__project_dir}/certs"
  }

  start_test lifecycle clean
  run_test test_destroy
  run_test test_clean
  verify_test

  if [[ " ${PROJECT_PHASES[*]} " =~ [[:space:]]exit[[:space:]] ]]; then
    start_test phase clean
    test_phase exit
    verify_test
  fi
fi
