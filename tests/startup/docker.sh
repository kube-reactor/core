#======================
# Docker execution    |
#======================


function test_docker_image () {
  run docker image list

  echo "$TEST_OUTPUT"

  # verify_output "^argocd/nginx.+Synced.+Healthy"
  # verify_output "^argocd/reloader.+Synced.+Healthy"
}

function test_docker_ps () {
  run docker ps -a

  echo "$TEST_OUTPUT"

  # verify_output "^argocd/nginx.+Synced.+Healthy"
  # verify_output "^argocd/reloader.+Synced.+Healthy"
}

function test_seq () {
  tag system docker

  add_tag image
  run_test test_docker_image

  add_tag service process
  run_test test_docker_ps
}
