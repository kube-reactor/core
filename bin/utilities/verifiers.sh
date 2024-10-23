#
#=========================================================================================
# Command Test Verifier Library
#
# Note: This test library does not have access to the reactor environment.
#       It is loaded in a new terminal session by the run_session test script.
#
# Has access to directories:
#
# * __test_dir
# * __reactor_dir
# * __script_dir
# * __projects_dir
# * __project_dir
# * __project_test_dir
#
# Has access to state:
#
# * TEST_PHASE
# * TEST_FILE
# * TEST_NAME
# * TEST_COMMAND
# * TEST_OUTPUT
#

function verify_output () {
  if ! echo "${TEST_OUTPUT:-}" | grep -P "$1" 1>/dev/null 2>&1; then
    fail "Searched value ${1} was not found in command output"
  fi
}

function verify_no_output () {
  if echo "${TEST_OUTPUT:-}" | grep -P "$1" 1>/dev/null 2>&1; then
    fail "Searched value ${1} was found in command output"
  fi
}


function verify_dir () {
  if [ ! -d "$1" ]; then
    fail "Directory ${1} does not exist"
  fi
}

function verify_no_dir () {
  if [ -d "$1" ]; then
    fail "Directory ${1} exists"
  fi
}

function verify_file () {
  if [ ! -f "$1" ]; then
    fail "File ${1} does not exist"
  fi
}

function verify_no_file () {
  if [ -f "$1" ]; then
    fail "File ${1} exists"
  fi
}


function verify_host () {
  if ! cat /etc/hosts | grep "$1" 1>/dev/null 2>/dev/null; then
    fail "Reactor host ${1} does not exist"
  fi
}

function verify_no_host () {
  if cat /etc/hosts | grep "$1" 1>/dev/null 2>/dev/null; then
    fail "Reactor host ${1} exists"
  fi
}
