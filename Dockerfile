FROM centos:centos7
MAINTAINER Yuntaz <docker@yuntaz.com>

ARG VERTICA_PACKAGE="vertica-8.0.1-0.x86_64.RHEL6.rpm"

ENV LANG en_US.utf8
ENV TZ UTC
ENV SHELL "/bin/bash"

USER root

RUN chsh -s /bin/bash
RUN yum -q -y update 
RUN yum update tzdata 
RUN bash -c 'systemctl mask firewalld'
RUN bash -c 'systemctl disable firewalld'
RUN bash -c '/sbin/service ntpd restart'
RUN bash -c '/sbin/chkconfig ntpd on' 
RUN yum -q -y install openssl curl 
RUN /usr/bin/curl -o /usr/local/bin/gosu -SL 'https://github.com/tianon/gosu/releases/download/1.1/gosu' 
RUN /bin/chmod +x /usr/local/bin/gosu 
RUN /usr/sbin/groupadd -r verticadba 
RUN /usr/sbin/useradd -r -m -s /bin/bash -g verticadba dbadmin 
RUN /usr/local/bin/gosu dbadmin mkdir /tmp/.python-eggs 
RUN yum install -y dialog iproute which mcelog gdb sysstat openssh-server openssh-clients 
RUN echo session required pam_limits.so >> /etc/pam.d/su
RUN sysctl -w kernel.pid_max=524288 
RUN echo never > /sys/kernel/mm/redhat_transparent_hugepage/enabled
RUN /usr/bin/curl -o /tmp/${VERTICA_PACKAGE} 'http://downloads.yuntaz.com/vertica/${VERTICA_PACKAGE}'  
RUN yum localinstall -q -y /tmp/${VERTICA_PACKAGE}

USER dbadmin

RUN chsh -s /bin/bash
RUN /opt/vertica/sbin/install_vertica --license CE --accept-eula --hosts 127.0.0.1 --dba-user-password-disabled --failure-threshold NONE --no-system-configuration
RUN gosu dbadmin /opt/vertica/bin/admintools -t create_db -s localhost -d docker -c /home/dbadmin/docker/catalog -D /home/dbadmin/docker/data

USER root

RUN /bin/rm -f /tmp/vertica*

ENV PYTHON_EGG_CACHE /tmp/.python-eggs
ENV VERTICADATA /home/dbadmin/docker
VOLUME /home/dbadmin/docker
ENTRYPOINT ["/opt/vertica/bin/docker-entrypoint.sh"]
ADD ./docker-entrypoint.sh /opt/vertica/bin/

EXPOSE 5433