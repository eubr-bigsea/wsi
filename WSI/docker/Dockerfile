# Copyright 2017 <Biagio Festa>
FROM ubuntu:16.04
MAINTAINER biagio.festa[at]gmail.com

ENV WSI_REPOSITORY https://github.com/eubr-bigsea/wsi.git
ENV WSI_VERSION 0.0.1-SNAPSHOT
ENV WSI_DB_VERSION 0.0.1-SNAPSHOT
ENV TOMCAT_VERSION_MAJOR 7
ENV TOMCAT_VERSION 7.0.79
ENV TOMCAT_REPO http://archive.apache.org/dist/tomcat
ENV CATALINA_HOME /opt/apache-tomcat-${TOMCAT_VERSION}
ENV PATH $CATALINA_HOME/bin:$PATH
ENV WSI_USER wsi
ENV WSI_HOME /home/${WSI_USER}
ENV WSI_CONFIG_FILE ${WSI_HOME}/wsi_config.xml
ENV OPT_JR_REPOSITORY https://github.com/eubr-bigsea/opt_jr
ENV OPT_JR_HOME /opt/opt_jr
ENV OPT_JR_CMD ${OPT_JR_HOME}/OPT_JR
ENV WS_DAGSIM_REPOSITORY https://github.com/eubr-bigsea/WS_DagSim
ENV DAGSIM_REPOSITORY https://github.com/eubr-bigsea/dagSim
ENV DAGSIM_HOME /opt/dagSim
ENV LUNDSTROM_REPOSITORY https://github.com/eubr-bigsea/lundstrom
ENV LUNDSTROM_HOME /opt/lundstrom
ENV WS_LUNDSTROM_REPOSITORY https://github.com/eubr-bigsea/lundstrom-ws
ENV OPT_COMMON_REPOSITORY https://github.com/eubr-bigsea/OPT_Common
ENV OPT_COMMON_HOME /opt/OPT_Common
ENV OPT_IC_REPOSITORY https://github.com/eubr-bigsea/OPT_IC
ENV OPT_IC_HOME /opt/OPT_IC
ENV OPT_DEADLINE_REPOSITORY https://github.com/eubr-bigsea/OPT_Deadline
ENV OPT_DEADLINE_HOME /opt/OPT_Deadline
ENV OPT_DATA_CONFIG https://github.com/eubr-bigsea/OPT_DATA_CONFIG
ENV EXAMPLE_DATA_HOME /home/work/
ENV SPARK_LOG_PARSER_REPO https://github.com/eubr-bigsea/SparkLogParser
ENV SPARK_LOG_PARSER_HOME /opt/SparkLogParser
ENV WSI_PASSWORD w51p455w0rd

# Install environment dependencies
RUN apt-get update && apt-get install -y nano vim git maven openjdk-8-jdk wget make gcc libmysqlclient-dev liblua5.3-dev python2.7 python vsftpd curl openmpi-bin openmpi-doc libopenmpi-dev

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
    cp target/WSI-${WSI_VERSION}.war /opt/apache-tomcat-${TOMCAT_VERSION}/webapps/WSI.war && \
    cd /tarball/wsi/WSI_DB && \
    mvn initialize && \
    mvn compile && \
    mvn package && \
    cp target/WSI_DB-${WSI_DB_VERSION}.war /opt/apache-tomcat-${TOMCAT_VERSION}/webapps/WSI_DB.war


# Create user ${WSI_USER} and give him privileges on ${CATALINA_HOME} (tomcat install directory)
RUN useradd -ms /bin/bash ${WSI_USER} && \
    chown -R ${WSI_USER}:${WSI_USER} ${CATALINA_HOME} && \
    echo "${WSI_USER}:${WSI_PASSWORD}" | chpasswd

# Download and install optmizer
RUN cd /tarball && \
    git clone ${OPT_JR_REPOSITORY} && \
    cd opt_jr/Release && \
    make && \
    mkdir -p ${OPT_JR_HOME} && \
    install -D -o ${WSI_USER} -g ${WSI_USER} OPT_JR ${OPT_JR_CMD}

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

# Download and install OPT_Common
RUN cd /tarball && \
    git clone ${OPT_COMMON_REPOSITORY} && \
    mkdir -p ${OPT_COMMON_HOME} && \
    cp -r OPT_Common/* ${OPT_COMMON_HOME} && \
    chown -R ${WSI_USER}:${WSI_USER} ${OPT_COMMON_HOME}

# Download and install OPT_IC
RUN cd /tarball && \
    git clone ${OPT_IC_REPOSITORY} && \
    cd OPT_IC && \
    make CXXINCLUDES="-I${OPT_COMMON_HOME}/include" && \
    mkdir -p ${OPT_IC_HOME} && \
    mkdir -p ${OPT_IC_HOME}/data && \
    mkdir -p ${OPT_IC_HOME}/lua && \
    cp src/opt_ic ${OPT_IC_HOME}/ && \
    cp config.txt ${OPT_IC_HOME} && \
    cp script.sh  ${OPT_IC_HOME} && \
    chown -R ${WSI_USER}:${WSI_USER} ${OPT_IC_HOME} && \
    chmod ugo+x ${OPT_IC_HOME}/script.sh && \
    echo "${OPT_IC_HOME}/data/" > ${OPT_IC_HOME}/config.txt && \
    echo "${DAGSIM_HOME}/" >> ${OPT_IC_HOME}/config.txt && \
    echo "${OPT_IC_HOME}/lua/" >> ${OPT_IC_HOME}/config.txt

# Download and install OPT_Deadline
RUN cd /tarball && \
    git clone ${OPT_DEADLINE_REPOSITORY} && \
    cd OPT_Deadline && \
    make OPT_COMMON_INCLUDE="-I${OPT_COMMON_HOME}/include" && \
    mkdir -p ${OPT_DEADLINE_HOME} && \
    cp opt_deadline ${OPT_DEADLINE_HOME} && \
    chown -R ${WSI_USER}:${WSI_USER} ${OPT_DEADLINE_HOME}
    

# Download and install Spark Parse Log
RUN cd /tarball && \
    git clone ${SPARK_LOG_PARSER_REPO} && \
    cp -r SparkLogParser ${SPARK_LOG_PARSER_HOME} && \
    cat SparkLogParser/config.sh | sed "s|DAGSIM=.*$|DAGSIM=${DAGSIM_HOME}/dagsim.sh|g" > ${SPARK_LOG_PARSER_HOME}/config.sh && \
    chown -R ${WSI_USER}:${WSI_USER} ${SPARK_LOG_PARSER_HOME} && \
    chmod ugo+x ${SPARK_LOG_PARSER_HOME}/process_logs.sh && \
    chmod ugo+x ${SPARK_LOG_PARSER_HOME}/summarize.sh

# Download example data
RUN cd /tarball && \
    git clone ${OPT_DATA_CONFIG}

# Prepare path for example data
RUN mkdir -p ${EXAMPLE_DATA_HOME} && \
    chown -R ${WSI_USER}:${WSI_USER} $(dirname ${EXAMPLE_DATA_HOME})

# Copy Configuration file
COPY wsi_config.xml ${WSI_CONFIG_FILE}
RUN chown ${WSI_USER}:${WSI_USER} ${WSI_CONFIG_FILE}
RUN chmod ugo+x /tarball/wsi/scripts/update_wsi_config.sh

# Go on user
USER ${WSI_USER}
WORKDIR ${WSI_HOME}

# Update wsi_config.xml
RUN /tarball/wsi/scripts/update_wsi_config.sh

# Create directory for upload
RUN mkdir ${WSI_HOME}/Uploaded

# Copy example datas
RUN cd ${EXAMPLE_DATA_HOME} && \
    tar -zxvf /tarball/OPT_DATA_CONFIG/LogP8.tar.gz && \
    cp -r /tarball/OPT_DATA_CONFIG/LogBS . || :

EXPOSE 8080

# Default command launch tomcat
CMD ["/bin/bash", "-c", "/tarball/wsi/scripts/update_wsi_config.sh && catalina.sh run;"]

