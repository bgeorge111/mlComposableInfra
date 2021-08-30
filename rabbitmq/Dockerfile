FROM rabbitmq:3.8-management
ARG _PLUGINS_FILE=rabbitmq_plugins.txt
ARG _DEFINITIONS_FILE=rabbitmq_definitions.json
COPY ./rabbitmq/${_PLUGINS_FILE} /etc/rabbitmq/enabled_plugins
COPY ./rabbitmq/${_DEFINITIONS_FILE} /etc/rabbitmq/definitions.json

