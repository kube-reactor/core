#
# ArgoCD environment configurations
#
export ARGOCD_PROJECT_SEQUENCE='[
  "system",
  "platform",
  "database",
  "management"
]'
#
# Cluster environment configurations
#
export GATEWAY_NODE_PORT=32210
#
# Zimagi environment configurations
#
export ZIMAGI_GITHUB_ORG="zimagi"
#
# Interface environment configurations
#
export INTERFACE_FROM_EMAIL="hello@fractalsynapse.com"
export INTERFACE_CONTACT_EMAIL="hello@fractalsynapse.com"

#
# Normally private configurations for testing
#
# These should really go in 'env/local/secret.sh'
#
export POSTGRESQL_PASSWORD="postgresql"
export REDIS_PASSWORD="redis"
export QDRANT_PASSWORD="qdrant"

export ZIMAGI_SECRET_KEY="111111111111111111"
export ZIMAGI_ADMIN_API_KEY="zimagi"

export ZIMAGI_EMAIL_HOST_USER=""
export ZIMAGI_EMAIL_HOST_PASSWORD=""

export INTERFACE_API_KEY=""
export INTERFACE_SECRET_KEY="111111111111111111"

export MAILGUN_DOMAIN=""
export MAILGUN_API_KEY=""
export MAILGUN_WEBHOOK_KEY=""

export HUGGINGFACE_API_TOKEN=""
export DEEPINFRA_API_KEY=""
