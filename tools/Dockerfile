FROM centos:latest
ARG _GRADLE_ZIP
ARG _HUB_CENTRAL_WAR
ARG _MLCP_ZIP
COPY ./tools/${_GRADLE_ZIP} /tmp/${_GRADLE_ZIP}
COPY ./tools/${_HUB_CENTRAL_WAR} /tmp/${_HUB_CENTRAL_WAR}
COPY ./tools/${_HUB_CENTRAL_CE_WAR} /tmp/${_HUB_CENTRAL_CE_WAR}
COPY ./tools/${_MLCP_ZIP} /tmp/${_MLCP_ZIP}
COPY ./env1.env /tmp/installEnv.env
COPY ./tools/init.sh /tmp/init.sh