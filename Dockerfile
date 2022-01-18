FROM centos
MAINTAINER sanjay
USER root
RUN yum update && apt-get install -y
RUN yum install libselinux-dev -y





# passwordless ssh
RUN ssh-keygen -q -N "" -t dsa -f /etc/ssh/ssh_host_dsa_key
RUN ssh-keygen -q -N "" -t rsa -f /etc/ssh/ssh_host_rsa_key
RUN ssh-keygen -q -N "" -t rsa -f /root/.ssh/id_rsa
RUN cp /root/.ssh/id_rsa.pub /root/.ssh/authorized_keys


## java part 
RUN curl -O https://download.java.net/openjdk/jdk8u41/ri/openjdk-8u41-b04-linux-x64-14_jan_2020.tar.gz
RUN tar zxvf openjdk-8u41-b04-linux-x64-14_jan_2020.tar.gz
RUN mkdir /usr/local/java
RUN mv java-se-8u41-ri /usr/local/java
RUN rm -r openjdk-8u41-b04-linux-x64-14_jan_2020.tar.gz




## hadoop part
RUN curl -O   https://archive.apache.org/dist/hadoop/common/hadoop-2.10.1/hadoop-2.10.1.tar.gz
RUN mkdir /usr/local
RUN mv  hadoop-2.10.1.tar.gz /usr/local
RUN cd /usr/local && tar zxvf hadoop-2.10.1.tar.gz
RUN ln -s hadoop-2.10.1 hadoop


## all environment 
ENV JAVA_HOME /usr/local/java/java-se-8u41-ri
ENV PATH $PATH:$JAVA_HOME/bin

ENV HADOOP_HOME /usr/local/hadoop
ENV HADOOP_INSTALL $HADOOP_HOME
ENV HDFS_NAMENODE_USER root
ENV HDFS_DATANODE_USER root
ENV HDFS_SECONDARYNAMENODE_USER root
ENV YARN_RESOURCEMANAGER_USER root
ENV YARN_NODEMANAGER_USER root
ENV HADOOP_COMMON_HOME $HADOOP_HOME
ENV HADOOP_HDFS_HOME $HADOOP_HOME
ENV HADOOP_MAPRED_HOME $HADOOP_HOME
ENV HADOOP_YARN_HOME $HADOOP_HOME
ENV HADOOP_CONF_DIR /usr/local/hadoop/etc/hadoop
ENV HADOOP_COMMON_LIB_NATIVE_DIR $HADOOP_HOME/lib/native
ENV HADOOP_OPTS "-Djava.library.path=$HADOOP_HOME/lib/native"
ENV PATH $PATH:$HADOOP_HOME/sbin:$HADOOP_HOME/bin


RUN echo "JAVA_HOME=$JAVA_HOME" >> $HADOOP_HOME/etc/hadoop/hadoop-env.sh
RUN echo "HADOOP_HOME=$HADOOP_HOME" >> $HADOOP_HOME/etc/hadoop/hadoop-env.sh



# workingaround docker.io build error
RUN ls -la /usr/local/hadoop/etc/hadoop/*-env.sh
RUN chmod +x /usr/local/hadoop/etc/hadoop/*-env.sh
RUN ls -la /usr/local/hadoop/etc/hadoop/*-env.sh



ADD core-site.xml.template $HADOOP_HOME/etc/hadoop/core-site.xml.template
RUN sed s/HOSTNAME/localhost/ /usr/local/hadoop/etc/hadoop/core-site.xml.template > /usr/local/hadoop/etc/hadoop/core-site.xml
ADD hdfs-site.xml $HADOOP_HOME/etc/hadoop/hdfs-site.xml
ADD mapred-site.xml $HADOOP_HOME/etc/hadoop/mapred-site.xml
ADD yarn-site.xml $HADOOP_HOME/etc/hadoop/yarn-site.xml





## init.sh
RUN $HADOOP_HOME/bin/hdfs namenode -format
RUN $HADOOP_HOME/sbin/start-dfs.sh
RUN $HADOOP_HOME/sbin/start-yarn.sh
RUN $HADOOP_HOME/sbin/mr-jobhistory-daemon.sh start historyserver



## bootstrap.sh
RUN $HADOOP_HOME/etc/hadoop/hadoop-env.sh
RUN rm /tmp/*.pid
RUN $HADOOP_HOME/sbin/start-dfs.sh
RUN $HADOOP_HOME/sbin/start-yarn.sh
RUN $HADOOP_HOME/sbin/mr-jobhistory-daemon.sh start historyserver








ENV PATH $PATH:$HADOOP_HOME/bin




## all about the ports
# Hdfs ports
EXPOSE 50010 50020 50070 50075 50090 8020 9000 50470 50475
#Yarn ports
EXPOSE 8030 8031 8032 8033 8040 8042 8088 8090 8050 8025 8141 45454 10200 8190 8188 
# Mapred ports
EXPOSE 10020 19888 13562 19890


ENTRYPOINT ["/bin/bash","RUN $HADOOP_HOME/etc/hadoop/hadoop-env.sh","RUN rm /tmp/*.pid","RUN $HADOOP_HOME/sbin/start-yarn.sh","RUN $HADOOP_HOME/sbin/start-yarn.sh","RUN $HADOOP_HOME/sbin/mr-jobhistory-daemon.sh start historyserver"]
CMD ["/bin/bash"]

