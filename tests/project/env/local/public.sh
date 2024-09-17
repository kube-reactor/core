#
# Cluster environment configurations
#
export GATEWAY_NODE_PORT=32210

#
# Zimagi environment configurations
#
export ZIMAGI_DEFAULT_MODULES='
[
  {
    "provider": "github",
    "remote": "fractalsynapse/nexical-core-engine",
    "reference": "main"
  }
]'

export ZIMAGI_SENTENCE_PARSER_PROVIDERS='["core_en_web"]'
export ZIMAGI_ENCODER_PROVIDERS='["mpnet_di"]'
export ZIMAGI_SUMMARIZER_PROVIDERS='["mixtral_di_7bx8"]'
