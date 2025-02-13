#
#=========================================================================================
# <Enter> Command
#
# Note: This command is implemented in the top level reactor script
#       due to the fact we need to shell into a running container.
#
# TODO: Perhaps there is a better way to do this so that implementation
#       of enter is in this command script?
#

if [ "${__os}" != "darwin" ]; then 
  function enter_description () {
    render "Launch a reactor container session"
  }
fi
