# Copyright 2017 <Marco Lattuada>
FROM mysql
MAINTAINER marco.lattuada@polimi.it

ARG MYSQL_ROOT_PASSWORD_ARG=b1g534
ARG MYSQL_USER_ARG=bigsea
ARG MYSQL_PASSWORD_ARG=b1g534

ENV MYSQL_ROOT_PASSWORD ${MYSQL_ROOT_PASSWORD_ARG}
ENV MYSQL_DATABASE bigsea
ENV MYSQL_USER ${MYSQL_USER_ARG}
ENV MYSQL_PASSWORD ${MYSQL_PASSWORD_ARG}

ADD creationDB.sql /docker-entrypoint-initdb.d/00_creationDb.sql
ADD insertBulmaProfile.sql /docker-entrypoint-initdb.d/01_insertBulmaProfile.sql
ADD insertBulmaData.sql /docker-entrypoint-initdb.d/02_insertBulmaData.sql
