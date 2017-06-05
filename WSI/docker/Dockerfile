FROM ubuntu:16.04
MAINTAINER biagio.festa[at]gmail.com

ENV WSI_REPOSITORY https://github.com/BiagioFesta/wsi_polimi.git
ENV WSI_VERSION 0.0.1-SNAPSHOT
ENV TOMCAT_VERSION_MAJOR 7
ENV TOMCAT_VERSION 7.0.78
ENV TOMCAT_REPO http://apache.panu.it/tomcat/
ENV CATALINA_HOME /opt/apache-tomcat-${TOMCAT_VERSION}
ENV PATH $CATALINA_HOME/bin:$PATH

RUN apt-get update && apt-get install -y git maven openjdk-8-jdk wget

RUN mkdir /tarball && \
    cd /tarball && \
    wget ${TOMCAT_REPO}/tomcat-${TOMCAT_VERSION_MAJOR}/v${TOMCAT_VERSION}/bin/apache-tomcat-${TOMCAT_VERSION}.tar.gz && \
    tar -zxvf apache-tomcat-${TOMCAT_VERSION}.tar.gz && \
    mkdir -p ${CATALINA_HOME} && \
    mv apache-tomcat-${TOMCAT_VERSION}/* ${CATALINA_HOME} && \
    rmdir apache-tomcat-${TOMCAT_VERSION}

RUN cd /tarball && \
    git clone ${WSI_REPOSITORY} && \
    cd wsi_polimi/WSI && \
    mvn initialize && \
    mvn compile && \
    mvn package && \
    cp target/WSI-${WSI_VERSION}.war /opt/apache-tomcat-${TOMCAT_VERSION}/webapps/WSI.war

ENV WSI_USER wsi
ENV WSI_HOME /home/${WSI_USER}
ENV WSI_CONFIG_FILE ${WSI_HOME}/wsi_config.xml

RUN useradd -ms /bin/bash ${WSI_USER} && \
    chown -R ${WSI_USER}:${WSI_USER} /opt/apache-tomcat-${TOMCAT_VERSION}

USER ${WSI_USER}
WORKDIR /home/wsi

RUN cp /tarball/wsi_polimi/WSI/config_example/wsi_config.xml ${WSI_CONFIG_FILE}

EXPOSE 8080

CMD ["catalina.sh", "run"]
    
