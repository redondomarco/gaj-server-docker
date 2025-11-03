#FROM debian:buster
FROM debian:stretch

#COPY conf/debian-buster.list /etc/apt/sources.list

COPY conf/debian-stretch.list /etc/apt/sources.list


RUN apt-get update

RUN DEBIAN_FRONTEND=noninteractive apt-get install -y --no-install-recommends \
    htop vim zip unzip bash-completion wget git curl locate less wget openjdk-11-jre-headless \
    maven   

RUN updatedb

# Set environment variables for Tomcat
ENV CATALINA_HOME=/usr/local/tomcat
ENV PATH=$CATALINA_HOME/bin:$PATH

# Set environment variables for Java and Tomcat versions
ENV JAVA_HOME=/usr/lib/jvm/java-11-openjdk-amd64
ENV PATH=$PATH:$JAVA_HOME/bin
ENV CATALINA_HOME=/opt/tomcat
ENV TOMCAT_VERSION=9.0.31


# Download and extract Tomcat
WORKDIR /opt
RUN wget https://archive.apache.org/dist/tomcat/tomcat-9/v${TOMCAT_VERSION}/bin/apache-tomcat-${TOMCAT_VERSION}.tar.gz && \
    tar -xzf apache-tomcat-${TOMCAT_VERSION}.tar.gz && \
    mv apache-tomcat-${TOMCAT_VERSION} tomcat && \
    rm apache-tomcat-${TOMCAT_VERSION}.tar.gz

# Expose the default Tomcat port
EXPOSE 8080

# Define the command to run Tomcat when the container starts
#CMD ["/opt/tomcat/bin/catalina.sh", "run"]


CMD ["tail", "-f", "/dev/null"]


