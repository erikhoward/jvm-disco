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
ENV GRADLE_VERSION=4.7
ENV GRADLE_HOME=/opt/gradle/gradle-${GRADLE_VERSION}
ENV PATH="${GRADLE_HOME}/bin:${PATH}"

RUN wget -O gradle.zip https://services.gradle.org/distributions/gradle-${GRADLE_VERSION}-bin.zip \
    && mkdir /opt/gradle && unzip -d /opt/gradle gradle.zip

# https://github.com/gettyimages/docker-spark
# HADOOP
ENV HADOOP_VERSION 2.8.3
ENV HADOOP_HOME /usr/hadoop-$HADOOP_VERSION
ENV HADOOP_CONF_DIR=$HADOOP_HOME/etc/hadoop
ENV PATH $PATH:$HADOOP_HOME/bin
RUN curl -sL --retry 3 \
  "http://archive.apache.org/dist/hadoop/common/hadoop-$HADOOP_VERSION/hadoop-$HADOOP_VERSION.tar.gz" \
  | gunzip \
  | tar -x -C /usr/ \
 && rm -rf $HADOOP_HOME/share/doc \
 && chown -R root:root $HADOOP_HOME

# SPARK
ENV SPARK_VERSION 2.3.0
ENV SPARK_PACKAGE spark-${SPARK_VERSION}-bin-without-hadoop
ENV SPARK_HOME /usr/spark-${SPARK_VERSION}
ENV SPARK_DIST_CLASSPATH="$HADOOP_HOME/etc/hadoop/*:$HADOOP_HOME/share/hadoop/common/lib/*:$HADOOP_HOME/share/hadoop/common/*:$HADOOP_HOME/share/hadoop/hdfs/*:$HADOOP_HOME/share/hadoop/hdfs/lib/*:$HADOOP_HOME/share/hadoop/hdfs/*:$HADOOP_HOME/share/hadoop/yarn/lib/*:$HADOOP_HOME/share/hadoop/yarn/*:$HADOOP_HOME/share/hadoop/mapreduce/lib/*:$HADOOP_HOME/share/hadoop/mapreduce/*:$HADOOP_HOME/share/hadoop/tools/lib/*"
ENV PATH $PATH:${SPARK_HOME}/bin
RUN curl -sL --retry 3 \
  "https://www.apache.org/dyn/mirrors/mirrors.cgi?action=download&filename=spark/spark-${SPARK_VERSION}/${SPARK_PACKAGE}.tgz" \
  | gunzip \
  | tar x -C /usr/ \
 && mv /usr/$SPARK_PACKAGE $SPARK_HOME \
 && chown -R root:root $SPARK_HOME
