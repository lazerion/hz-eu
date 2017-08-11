FROM java:openjdk-8-jre
ENV HZ_VERSION 3.8.3
ENV HZ_HOME /opt/hazelcast/
RUN mkdir -p $HZ_HOME
WORKDIR $HZ_HOME

# User root while setup
USER root

# Download hazelcast jars from maven repo.
ADD https://repo1.maven.org/maven2/com/hazelcast/hazelcast/$HZ_VERSION/hazelcast-$HZ_VERSION.jar $HZ_HOME

# Discovery Plugin
ADD hazelcast-eureka-one-1.0-SNAPSHOT.jar $HZ_HOME

# Logging and Validation
ADD https://repo1.maven.org/maven2/org/slf4j/jul-to-slf4j/1.7.12/jul-to-slf4j-1.7.12.jar $HZ_HOME

### Adding JCache
ADD https://repo1.maven.org/maven2/javax/cache/cache-api/1.0.0/cache-api-1.0.0.jar $HZ_HOME

### Adding maven wrapper, downloading Hazelcast Kubernetes discovery plugin and dependencies and cleaning up
COPY mvnw $HZ_HOME/mvnw

ADD hazelcast.xml /$HZ_HOME/hazelcast.xml
ADD start.sh /$HZ_HOME/start.sh
ADD eureka-client.properties /$HZ_HOME/eureka-client.properties

RUN useradd -ms /bin/bash default
RUN chmod a+x /$HZ_HOME/start.sh
RUN chmod a+rw /$HZ_HOME/*

RUN cd mvnw && \
    chmod +x mvnw && \
    ./mvnw -f dependency-copy.xml dependency:copy-dependencies && \
    cd .. && \
    rm -rf $HZ_HOME/mvnw && \
    rm -rf $HZ_HOME/.m2 && \
    chmod -R +r $HZ_HOME

# User default when running
USER default
# Expose port
EXPOSE 5701

# Start hazelcast standalone server.
CMD ./start.sh
