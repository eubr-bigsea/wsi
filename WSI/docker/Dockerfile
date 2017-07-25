# Copyright 2017 <Biagio Festa>
FROM ubuntu:16.04
MAINTAINER biagio.festa[at]gmail.com

ENV WSI_REPOSITORY https://github.com/eubr-bigsea/wsi.git
ENV OPTIMIZE_REPOSITORY https://github.com/eubr-bigsea/opt_jr
ENV WSI_VERSION 0.0.1-SNAPSHOT
ENV TOMCAT_VERSION_MAJOR 7
ENV TOMCAT_VERSION 7.0.79
ENV TOMCAT_REPO http://apache.panu.it/tomcat/
ENV CATALINA_HOME /opt/apache-tomcat-${TOMCAT_VERSION}
ENV PATH $CATALINA_HOME/bin:$PATH
ENV WSI_USER wsi
ENV WSI_HOME /home/${WSI_USER}
ENV WSI_CONFIG_FILE ${WSI_HOME}/wsi_config.xml
ENV OPTIMIZE_HOME /opt/optimize
ENV OPTIMIZE_CMD ${OPTIMIZE_HOME}/optimize
ENV WS_DAGSIM_REPOSITORY https://github.com/eubr-bigsea/WS_DagSim
ENV DAGSIM_REPOSITORY https://github.com/eubr-bigsea/dagSim
ENV DAGSIM_HOME /opt/dagSim
ENV LUNDSTROM_REPOSITORY https://github.com/eubr-bigsea/lundstrom
ENV LUNDSTROM_HOME /opt/lundstrom
ENV WS_LUNDSTROM_REPOSITORY https://github.com/eubr-bigsea/lundstrom-ws
ENV OPT_IC_REPOSITORY https://github.com/eubr-bigsea/OPT_IC
ENV OPT_IC_HOME /opt/OPT_IC
ENV OPT_DATA_CONFIG https://github.com/eubr-bigsea/OPT_DATA_CONFIG
ENV EXAMPLE_DATA_HOME /home/work/TPCDS500-D_processed_logs
ENV SPARK_LOG_PARSER_REPO https://github.com/eubr-bigsea/SparkLogParser
ENV SPARK_LOG_PARSER_HOME /opt/SparkLogParser


# Install environment dependencies
RUN apt-get update && apt-get install -y nano git maven openjdk-8-jdk wget make gcc libmysqlclient-dev liblua5.3-dev python2.7

# Install tomcat in ${CATALINA_HOME}
RUN mkdir /tarball && \
    cd /tarball && \
    wget ${TOMCAT_REPO}/tomcat-${TOMCAT_VERSION_MAJOR}/v${TOMCAT_VERSION}/bin/apache-tomcat-${TOMCAT_VERSION}.tar.gz && \
    tar -zxvf apache-tomcat-${TOMCAT_VERSION}.tar.gz && \
    mkdir -p ${CATALINA_HOME} && \
    mv apache-tomcat-${TOMCAT_VERSION}/* ${CATALINA_HOME} && \
    rmdir apache-tomcat-${TOMCAT_VERSION}

# Download and install the web service application (deploy on tomcat)
RUN cd /tarball && \
    git clone ${WSI_REPOSITORY} wsi && \
    cd wsi/WSI && \
    mvn initialize && \
    mvn compile && \
    mvn package && \
    cp target/WSI-${WSI_VERSION}.war /opt/apache-tomcat-${TOMCAT_VERSION}/webapps/WSI.war

# Create user ${WSI_USER} and give him privileges on ${CATALINA_HOME} (tomcat install directory)
RUN useradd -ms /bin/bash ${WSI_USER} && \
    chown -R ${WSI_USER}:${WSI_USER} ${CATALINA_HOME}

# Download and install optmizer
RUN cd /tarball && \
    git clone ${OPTIMIZE_REPOSITORY} && \
    cd opt_jr && \
    make && \
    install -D -o ${WSI_USER} -g ${WSI_USER} optimize ${OPTIMIZE_CMD}

# Download and install DagSim
RUN cd /tarball && \
    git clone ${DAGSIM_REPOSITORY} && \
    cd dagSim && \
    make clean && \
    make && \
    chmod ugo+x dagsim.sh && \
    mkdir -p ${DAGSIM_HOME} && \
    cp -r ./* ${DAGSIM_HOME}/ && \
    chown -R ${WSI_USER}:${WSI_USER} ${DAGSIM_HOME}

#Download and install lundstrom
RUN cd /tarball && \
    git clone ${LUNDSTROM_REPOSITORY} && \
    cp -r lundstrom $(dirname ${LUNDSTROM_HOME}) && \
    chown -R ${WSI_USER}:${WSI_USER} ${LUNDSTROM_HOME}

# Download and install the WS_DagSim
RUN cd /tarball && \
    git clone ${WS_DAGSIM_REPOSITORY} && \
    cd WS_DagSim && \
    mvn initialize && \
    mvn compile && \
    mvn package && \
    install -D -o ${WSI_USER} -g ${WSI_USER} target/bigsea.war /opt/apache-tomcat-${TOMCAT_VERSION}/webapps/bigsea.war

# Download and install OPT_IC
RUN cd /tarball && \
    git clone ${OPT_IC_REPOSITORY} && \
    cd OPT_IC && \
    make && \
    cp -r /tarball/OPT_IC /opt && \
    chown -R ${WSI_USER}:${WSI_USER} ${OPT_IC_HOME} && \
    echo "" > ${OPT_IC_HOME}/config.txt && \
    echo "${OPT_IC_HOME}/data/" >> ${OPT_IC_HOME}/config.txt && \
    echo "${DAGSIM_HOME}/" >> ${OPT_IC_HOME}/config.txt && \
    echo "${OPT_IC_HOME}/lua/" >> ${OPT_IC_HOME}/config.txt 

# Download and install Spark Parse Log
RUN cd /tarball && \
    git clone ${SPARK_LOG_PARSER_REPO} && \
    cp -r SparkLogParser ${SPARK_LOG_PARSER_HOME} && \
    cat SparkLogParser/config.sh | sed "s|DAGSIM=.*$|DAGSIM=${DAGSIM_HOME}/dagsim.sh|g" > ${SPARK_LOG_PARSER_HOME}/config.sh && \
    chown -R ${WSI_USER}:${WSI_USER} ${SPARK_LOG_PARSER_HOME}

# Download example data
RUN cd /tarball && \
    git clone ${OPT_DATA_CONFIG}

# Prepare path for example data
RUN mkdir -p ${EXAMPLE_DATA_HOME} && \
    chown -R ${WSI_USER}:${WSI_USER} $(dirname ${EXAMPLE_DATA_HOME})

# Copy Configuration file
COPY wsi_config.xml ${WSI_CONFIG_FILE}
RUN chown ${WSI_USER}:${WSI_USER} ${WSI_CONFIG_FILE}

# Go on user
USER ${WSI_USER}
WORKDIR ${WSI_HOME}

# Create directory for upload
RUN mkdir ${WSI_HOME}/Uploaded

# Copy example datas
RUN cp /tarball/OPT_DATA_CONFIG/TPCDS500-D_processed_logs.tar.gz ${EXAMPLE_DATA_HOME} && \
    cd ${EXAMPLE_DATA_HOME} && \
    tar -zxvf TPCDS500-D_processed_logs.tar.gz -C ..

EXPOSE 8080

# Default command launch tomcat
CMD ["catalina.sh", "run"]
    
