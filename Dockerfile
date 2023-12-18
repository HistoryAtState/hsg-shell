# START STAGE 1
FROM openjdk:8-jdk-slim as builder

USER root

ENV NODE_MAJOR 18
# 14 
ENV ANT_VERSION 1.10.13
ENV ANT_HOME /etc/ant-${ANT_VERSION}

WORKDIR /tmp

RUN apt-get update && apt-get install -y \
    git \
    curl \
    ca-certificates \
    gnupg

RUN mkdir -p /etc/apt/keyrings && \
    curl -fsSL https://deb.nodesource.com/gpgkey/nodesource-repo.gpg.key | gpg --dearmor -o /etc/apt/keyrings/nodesource.gpg && \
    echo "deb [signed-by=/etc/apt/keyrings/nodesource.gpg] https://deb.nodesource.com/node_${NODE_MAJOR}.x nodistro main" | tee /etc/apt/sources.list.d/nodesource.list && \
    apt-get update && \
    apt-get install nodejs -y

RUN curl -L -o apache-ant-${ANT_VERSION}-bin.tar.gz http://www.apache.org/dist/ant/binaries/apache-ant-${ANT_VERSION}-bin.tar.gz \
    && mkdir ant-${ANT_VERSION} \
    && tar -zxvf apache-ant-${ANT_VERSION}-bin.tar.gz \
    && mv apache-ant-${ANT_VERSION} ${ANT_HOME} \
    && rm apache-ant-${ANT_VERSION}-bin.tar.gz \
    && rm -rf ant-${ANT_VERSION} \
    && rm -rf ${ANT_HOME}/manual \
    && unset ANT_VERSION

ENV PATH ${PATH}:${ANT_HOME}/bin

FROM builder as hsg

# add key
RUN  mkdir -p ~/.ssh && ssh-keyscan -t rsa github.com >> ~/.ssh/known_hosts

# Required XARs 
ARG TEMPLATING_VERSION=1.1.0
ARG TEI_PUBLISHER_LIB_VERSION=2.10.1
ARG EXPATH_CRYPTO_VERSION=6.0.1

RUN mkdir /tmp/binary-xars

RUN curl -L -o /tmp/binary-xars/00-templating-${TEMPLATING_VERSION}.xar http://exist-db.org/exist/apps/public-repo/public/templating-${TEMPLATING_VERSION}.xar
RUN curl -L -o /tmp/binary-xars/00-tei-publisher-lib-${TEI_PUBLISHER_LIB_VERSION}.xar https://exist-db.org/exist/apps/public-repo/public/tei-publisher-lib-${TEI_PUBLISHER_LIB_VERSION}.xar
RUN curl -L -o /tmp/binary-xars/00-expath-crypto-module-${EXPATH_CRYPTO_VERSION}.xar https://exist-db.org/exist/apps/public-repo/public/expath-crypto-module-${EXPATH_CRYPTO_VERSION}.xar
# RUN curl -L -o /tmp/binary-xars/01-tei-pm-1.1.4.xar https://exist-db.org/exist/apps/public-repo/public/tei-pm-1.1.4.xar

# Build XARs from source
RUN git clone --depth 1 -b master https://github.com/HistoryAtState/administrative-timeline.git
RUN cd administrative-timeline \
    && ant xar

RUN git clone --depth 1 -b master https://github.com/HistoryAtState/carousel.git
RUN cd carousel \
    && ant xar

RUN git clone --depth 1 -b master https://github.com/HistoryAtState/conferences.git
RUN cd conferences \
    && ant xar

RUN git clone --depth 1 -b master https://github.com/joewiz/gsh.git
RUN cd gsh \
     && ant xar

RUN git clone --depth 1 -b master https://github.com/HistoryAtState/hac.git
RUN cd hac \
     && ant xar

RUN git clone --depth 1 -b playground https://github.com/windauer/hsg-shell.git
RUN cd hsg-shell \
    && ant xar

RUN  git clone --depth 1 -b master https://github.com/HistoryAtState/milestones.git
RUN cd milestones \
     && ant xar

RUN git clone --depth 1 -b master https://github.com/HistoryAtState/other-publications.git 
RUN cd other-publications \
     && ant xar

RUN git clone --depth 1 -b master https://github.com/HistoryAtState/pocom.git
RUN cd pocom \
     && ant xar

RUN git clone --depth 1 -b master https://github.com/HistoryAtState/rdcr.git
RUN cd rdcr \
     && ant xar

RUN git clone --depth 1 -b master https://github.com/HistoryAtState/release.git
RUN cd release \
     && ant xar

RUN git clone --depth 1 -b master https://github.com/HistoryAtState/tags.git
RUN cd tags \
     && ant xar

RUN git clone --depth 1 -b master https://github.com/HistoryAtState/terms.git
RUN cd terms \
     && ant xar

RUN git clone --depth 1 -b master https://github.com/HistoryAtState/travels.git
RUN cd travels \
     && ant xar

RUN git clone --depth 1 -b master https://github.com/HistoryAtState/twitter.git
RUN cd twitter \
     && ant xar

RUN git clone --depth 1 -b master https://github.com/HistoryAtState/visits.git
RUN cd visits \
     && ant xar

RUN git clone --depth 1 -b master https://github.com/HistoryAtState/wwdai.git
RUN cd wwdai \
     && ant xar

# (DP) Archived switch to aws.xq?
# see 
RUN git clone --depth 1 -b master https://github.com/joewiz/s3.git
RUN cd s3 \
     && ant xar

RUN  git clone --depth 1 -b master https://github.com/HistoryAtState/frus-history.git
RUN cd frus-history \
    && ant xar

# (DP) see https://github.com/Jinntec/hsg-project/issues/1
RUN  git clone --depth 1 -b master https://github.com/HistoryAtState/frus-not-yet-reviewed.git
RUN cd frus-not-yet-reviewed \
    && ant xar

RUN  git clone --depth 1 -b master https://github.com/HistoryAtState/frus.git
RUN cd frus \
    && ant xar

FROM duncdrum/existdb:${EXIST_VER}-debug-j8
ARG EXIST_VER=latest

COPY --from=hsg /tmp/binary-xars/*.xar /exist/autodeploy/
COPY --from=hsg /tmp/administrative-timeline/build/*.xar /exist/autodeploy/
COPY --from=hsg /tmp/carousel/build/*.xar /exist/autodeploy/
COPY --from=hsg /tmp/conferences/build/*.xar /exist/autodeploy/
COPY --from=hsg /tmp/gsh/build/*.xar /exist/autodeploy/
COPY --from=hsg /tmp/hac/build/*.xar /exist/autodeploy/
COPY --from=hsg /tmp/hsg-shell/build/*.xar /exist/autodeploy/
COPY --from=hsg /tmp/milestones/build/*.xar /exist/autodeploy/
COPY --from=hsg /tmp/other-publications/build/*.xar /exist/autodeploy/
COPY --from=hsg /tmp/pocom/build/*.xar /exist/autodeploy/
COPY --from=hsg /tmp/rdcr/build/*.xar /exist/autodeploy/
COPY --from=hsg /tmp/release/build/*.xar /exist/autodeploy/
COPY --from=hsg /tmp/tags/build/*.xar /exist/autodeploy/
COPY --from=hsg /tmp/terms/build/*.xar /exist/autodeploy/
COPY --from=hsg /tmp/travels/build/*.xar /exist/autodeploy/
COPY --from=hsg /tmp/twitter/build/*.xar /exist/autodeploy/
COPY --from=hsg /tmp/visits/build/*.xar /exist/autodeploy/
COPY --from=hsg /tmp/wwdai/build/*.xar /exist/autodeploy/
COPY --from=hsg /tmp/s3/build/*.xar /exist/autodeploy/
COPY --from=hsg /tmp/frus-history/build/*.xar /exist/autodeploy/
COPY --from=hsg /tmp/frus-not-yet-reviewed/build/*.xar /exist/autodeploy/
COPY --from=hsg /tmp/frus/build/*.xar /exist/autodeploy/zz-frus.xar

WORKDIR /exist

# ARG ADMIN_PASS=none

ARG HTTP_PORT=8080
ARG HTTPS_PORT=8443

ENV JAVA_TOOL_OPTIONS \
  -Dfile.encoding=UTF8 \
  -Dsun.jnu.encoding=UTF-8 \
  -Djava.awt.headless=true \
  -Dorg.exist.db-connection.cacheSize=${CACHE_MEM:-256}M \
  -Dorg.exist.db-connection.pool.max=${MAX_BROKER:-20} \
  -Dlog4j.configurationFile=/exist/etc/log4j2.xml \
  -Dexist.home=/exist \
  -Dexist.configurationFile=/exist/etc/conf.xml \
  -Djetty.home=/exist \
  -Dexist.jetty.config=/exist/etc/jetty/standard.enabled-jetty-configs \  
  -XX:+UseG1GC \
  -XX:+UseStringDeduplication \
  -XX:+UseContainerSupport \
  -XX:MaxRAMPercentage=${JVM_MAX_RAM_PERCENTAGE:-75.0} \
  -XX:+ExitOnOutOfMemoryError

# pre-populate the database by launching it once and change default pw
RUN [ "java", "org.exist.start.Main", "client", "--no-gui",  "-l", "-u", "admin", "-P", "" ]

EXPOSE ${HTTP_PORT} ${HTTPS_PORT}