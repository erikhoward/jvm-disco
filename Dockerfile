FROM maven:3.5-jdk-10
LABEL maintainer "Erik Howard <erikhoward@protonmail.com>"

ENV DEBIAN_FRONTEND noninteractive
ENV APT_KEY_DONT_WARN_ON_DANGEROUS_USAGE=1

RUN set -e \
    && ln -sf /bin/bash /bin/sh

RUN echo "deb https://dl.bintray.com/sbt/debian /" | tee -a /etc/apt/sources.list.d/sbt.list \
    && apt-key adv --keyserver hkp://keyserver.ubuntu.com:80 --recv 2EE0EA64E40A89B84B2DF73499E82A75642AC823

RUN apt-get update -y && apt-get upgrade -y \
    && apt-get install -y \
    apt-transport-https \
    curl \
    git \
    gnupg2 \
    mercurial \
    openssl \
    sbt \
    wget \
    unzip \
    zip \
    ca-certificates \
    --no-install-recommends \      
    && apt-get -y autoremove \
    && apt-get clean

# Install Kotlin
ENV KOTLIN_HOME=/usr/local/kotlin
ENV KOTLIN_VERSION=1.2.41

RUN cd /tmp && \
    wget -k "https://github.com/JetBrains/kotlin/releases/download/v${KOTLIN_VERSION}/kotlin-compiler-${KOTLIN_VERSION}.zip"  && \
    unzip "kotlin-compiler-${KOTLIN_VERSION}.zip" && \
    mkdir -p "${KOTLIN_HOME}" && \
    mv "/tmp/kotlinc/bin" "/tmp/kotlinc/lib" "${KOTLIN_HOME}" && \
    rm ${KOTLIN_HOME}/bin/*.bat && \
    chmod +x ${KOTLIN_HOME}/bin/* && \
    ln -s "${KOTLIN_HOME}/bin/"* "/usr/bin/"

# Install scala
RUN wget -O- "http://downloads.lightbend.com/scala/2.12.6/scala-2.12.6.tgz" \
    | tar xzf - -C /usr/local --strip-components=1

# Install gradle
ENV GRADLE_VERSION=3.4.1
RUN wget https://services.gradle.org/distributions/gradle-${GRADLE_VERSION}-bin.zip \
    
WORKDIR /root
