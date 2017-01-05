FROM centos:centos7
MAINTAINER Yuntaz <docker@yuntaz.com>

ARG VERTICA_PACKAGE="vertica-8.0.1-0.x86_64.RHEL6.rpm"

ENV LANG en_US.utf8
ENV TZ UTC
ENV SHELL "/bin/bash"

RUN yum -q -y update \
 && yum update tzdata \
 && systemctl mask firewalld \
 && systemctl disable firewalld \ 
 && systemctl stop firewalld \
 && /sbin/service ntpd restart \
 && /sbin/chkconfig ntpd on \
 && yum -q -y install openssl curl \
 && /usr/bin/curl -o /usr/local/bin/gosu -SL 'https://github.com/tianon/gosu/releases/download/1.1/gosu' \
 && /bin/chmod +x /usr/local/bin/gosu \
 && /usr/sbin/groupadd -r verticadba \
 && /usr/sbin/useradd -r -m -s /bin/bash -g verticadba dbadmin \
 && /usr/local/bin/gosu dbadmin mkdir /tmp/.python-eggs \
 && yum install -y dialog iproute which mcelog gdb sysstat openssh-server openssh-clients \
 && echo session required pam_limits.so >> /etc/pam.d/su \
 && sysctl -w kernel.pid_max=524288 \
 && echo never > /sys/kernel/mm/redhat_transparent_hugepage/enabled


RUN /usr/bin/curl -o /tmp/${VERTICA_PACKAGE} 'http://downloads.yuntaz.com/vertica/${VERTICA_PACKAGE}'  \
 && yum localinstall -q -y /tmp/${VERTICA_PACKAGE}

RUN /opt/vertica/sbin/install_vertica --license CE --accept-eula --hosts 127.0.0.1 --dba-user-password-disabled --failure-threshold NONE --no-system-configuration \
 && gosu dbadmin /opt/vertica/bin/admintools -t create_db -s localhost -d docker -c /home/dbadmin/docker/catalog -D /home/dbadmin/docker/data \
 && /bin/rm -f /tmp/vertica*

ENV PYTHON_EGG_CACHE /tmp/.python-eggs
ENV VERTICADATA /home/dbadmin/docker
VOLUME /home/dbadmin/docker
ENTRYPOINT ["/opt/vertica/bin/docker-entrypoint.sh"]
ADD ./docker-entrypoint.sh /opt/vertica/bin/

EXPOSE 5433