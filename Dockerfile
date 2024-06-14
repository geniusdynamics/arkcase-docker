###########################################################################################################
#
# How to build:
#
# docker build -t arkcase/artifacts:latest .
#
###########################################################################################################

#
# Basic Definitions
#
ARG EXT="core"
ARG VER="2023.02.03"

#
# Basic Parameters
#
ARG PUBLIC_REGISTRY="public.ecr.aws"
ARG BASE_REPO="arkcase/artifacts"
ARG BASE_VER="1.4.2"
ARG BASE_IMG="${PUBLIC_REGISTRY}/${BASE_REPO}:${BASE_VER}"

#
# The repo from which to pull everything
#
ARG ARKCASE_MVN_REPO="https://nexus.armedia.com/repository/arkcase/"

#
# ArkCase WAR and CONF files
#
ARG ARKCASE_SRC="com.armedia.acm.acm-standard-applications:arkcase:${VER}:war"

ARG CONF_VER="${VER}"
ARG CONF_SRC="com.armedia.arkcase:arkcase-config-${EXT}:${CONF_VER}:zip"

#
# The PDFNet library and binaries
#
ARG PDFTRON_VER="9.3.0"
ARG PDFTRON_SRC="com.armedia.arkcase:arkcase-pdftron-bin:${PDFTRON_VER}:jar"

FROM "${BASE_IMG}"

ARG VER
ENV VER="${VER}"

#
# Basic Parameters
#

LABEL ORG="ArkCase LLC" \
      MAINTAINER="Armedia Devops Team <devops@armedia.com>" \
      APP="ArkCase Deployer" \
      VERSION="${VER}"

ENV ARKCASE_DIR="${FILE_DIR}/arkcase"
ENV ARKCASE_CONF_DIR="${ARKCASE_DIR}/conf"
ENV ARKCASE_EXTS_DIR="${ARKCASE_DIR}/exts"
ENV ARKCASE_WARS_DIR="${ARKCASE_DIR}/wars"

ENV PENTAHO_DIR="${FILE_DIR}/pentaho"
ENV PENTAHO_ANALYTICAL_DIR="${PENTAHO_DIR}/analytical"
ENV PENTAHO_REPORTS_DIR="${PENTAHO_DIR}/reports"

#
# Make sure the base tree is created properly
#
RUN for n in \
        "${ARKCASE_DIR}" \
        "${ARKCASE_CONF_DIR}" \
        "${ARKCASE_WARS_DIR}" \
        "${ARKCASE_EXTS_DIR}" \
        "${PENTAHO_DIR}" \
        "${PENTAHO_ANALYTICAL_DIR}" \
        "${PENTAHO_REPORTS_DIR}" \
    ; do mkdir -p "${n}" ; done

#
# TODO: Eventually add the Solr and Alfresco trees in here
#

#
# Maven auth details
#
ARG MVN_GET_ENCRYPTION_KEY
ARG MVN_GET_USERNAME
ARG MVN_GET_PASSWORD

#
# Import the repo
#
ARG ARKCASE_MVN_REPO

#
# Pull all the artifacts
#
# The artifacts are pulled in this specific order to facilitate
# developers' lives when building the containers locally for testing,
# such that they can leverage layer caching as much as possible
#

# First PDFTron, since this is the artifact least likely to change
ARG PDFTRON_SRC
ENV PDFTRON_TGT="${ARKCASE_CONF_DIR}/00-pdftron.zip"
RUN mvn-get "${PDFTRON_SRC}" "${ARKCASE_MVN_REPO}" "${PDFTRON_TGT}"

# Then the ArkCase config, since that's the 2nd least likely to change
ARG CONF_SRC
ENV CONF_TGT="${ARKCASE_CONF_DIR}/00-conf.zip"
RUN mvn-get "${CONF_SRC}"    "${ARKCASE_MVN_REPO}" "${CONF_TGT}"

# Finally, ArkCase, since it's the likeliest to change
ARG ARKCASE_SRC
ENV ARKCASE_TGT="${ARKCASE_WARS_DIR}/arkcase.war"
RUN mvn-get "${ARKCASE_SRC}" "${ARKCASE_MVN_REPO}" "${ARKCASE_TGT}"