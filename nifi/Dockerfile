FROM apache/nifi:latest
ARG _NIFI_ML_CONNECTOR_JAR
ARG _NIFI_ML_SERVICES_JAR
COPY ./nifi/${_NIFI_ML_CONNECTOR_JAR} /opt/nifi/nifi-current/lib/${_NIFI_ML_CONNECTOR_JAR}
COPY ./nifi/${_NIFI_ML_SERVICES_JAR} /opt/nifi/nifi-current/lib/${_NIFI_ML_SERVICES_JAR}