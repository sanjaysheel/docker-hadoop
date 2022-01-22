#!/bin/bash
FROM ubuntu
MAINTAINER sanjay
USER root
# install packages
RUN apt-get clean  -y
RUN apt-get update -y && apt-get upgrade -y
RUN apt-get install ssh -y
RUN apt-get install vim -y
RUN apt-get install --fix-missing -y
RUN apt-get install openjdk-8-jdk -y
RUN apt-get install nano -y
RUN apt-get install curl -y
RUN apt-get install libselinux-dev -y





# passwordless ssh
# RUN ssh-keygen -q -N "" -t dsa -f /etc/ssh/ssh_host_dsa_key
# RUN ssh-keygen -q -N "" -t rsa -f /etc/ssh/ssh_host_rsa_key
# RUN ssh-keygen -q -N "" -t rsa -f /root/.ssh/id_rsa
# RUN cp /root/.ssh/id_rsa.pub /root/.ssh/authorized_keys


## java part 
# RUN curl -O https://download.java.net/openjdk/jdk8u41/ri/openjdk-8u41-b04-linux-x64-14_jan_2020.tar.gz
# RUN tar zxvf openjdk-8u41-b04-linux-x64-14_jan_2020.tar.gz
# RUN mkdir /usr/local/java
# RUN mv java-se-8u41-ri /usr/local/java && ls 
# RUN rm -r openjdk-8u41-b04-linux-x64-14_jan_2020.tar.gz



ENV HADOOP_HOME /opt/hadoop

ENV JAVA_HOME /usr/lib/jvm/java-8-openjdk-amd64

ENV HDFS_NAMENODE_USER root
ENV HDFS_DATANODE_USER root
ENV HDFS_SECONDARYNAMENODE_USER root
ENV YARN_RESOURCEMANAGER_USER root
ENV YARN_NODEMANAGER_USER root

ENV HADOOP_COMMON_HOME $HADOOP_HOME
ENV HADOOP_HDFS_HOME $HADOOP_HOME
ENV HADOOP_MAPRED_HOME $HADOOP_HOME
ENV HADOOP_YARN_HOME $HADOOP_HOME


ENV HADOOP_CONF_DIR $HADOOP_HOME/etc/hadoop
ENV HADOOP_COMMON_LIB_NATIVE_DIR $HADOOP_HOME/lib/native
ENV PATH $PATH:$HADOOP_HOME/sbin:$HADOOP_HOME/bin




## hadoop part
RUN curl -O   https://archive.apache.org/dist/hadoop/common/hadoop-2.10.1/hadoop-2.10.1.tar.gz
# RUN mkdir /usr/local
RUN tar -xzf hadoop-2.10.1.tar.gz


RUN mv hadoop-2.10.1 $HADOOP_HOME

RUN echo "export JAVA_HOME=$JAVA_HOME" >> $HADOOP_HOME/etc/hadoop/hadoop-env.sh 
RUN echo "PATH=$PATH:$HADOOP_HOME/bin" >> ~/.bashrc




ADD *xml $HADOOP_HOME/etc/hadoop/
ADD core-site.xml.template $HADOOP_HOME/etc/hadoop/core-site.xml.template
RUN sed s/HOSTNAME/localhost/ $HADOOP_HOME/etc/hadoop/core-site.xml.template > $HADOOP_HOME/etc/hadoop/core-site.xml

# RUN cd $HADOOP_HOME/etc/hadoop/ && chmod -x *-env.sh


# create ssh keys
RUN ssh-keygen -t rsa -P '' -f ~/.ssh/id_rsa && cat ~/.ssh/id_rsa.pub >> ~/.ssh/authorized_keys &&  chmod 0600 ~/.ssh/authorized_keys

ADD ssh_config /root/.ssh/config
## set environment vars
# ENV HADOOP_HOME /opt/hadoop
# ENV JAVA_HOME /usr/lib/jvm/java-8-openjdk-amd64




# copy hadoop configs



# copy ssh config
# ADD ssh_config /root/.ssh/config


# copy script to start hadoop
ADD start-hadoop.sh start-hadoop.sh







## all about the ports
# Hdfs ports
EXPOSE 50010 50020 50070 50075 50090 8020 9000 50470 50475 50030 50060
#Yarn ports
EXPOSE 8030 8031 8032 8033 8040 8042 8088 8090 8050 8025 8141 45454 10200 8190 8188 
# Mapred ports
EXPOSE 10020 19888 13562 19890




CMD bash start-hadoop.sh
