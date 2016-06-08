FROM centos:7
MAINTAINER Susumu

env CONSUL_TEMPLATE_VERSION 0.14.0
ENV CONSUL_URL consul:8500
ENV VARNISH_PORT 80
ENV VARNISH_STORAGE_BACKEND malloc,100M
ENV VARNISHNCSA_LOGFORMAT %h %l %u %t "%r" %s %b "%{Referer}i" "%{User-agent}i"

RUN    yum -y install epel-release \ 
	&& yum -y install curl supervisor unzip zip \
	&& rpm --import https://repo.varnish-cache.org//GPG-key.txt \
	&& rpm -Uvh https://repo.varnish-cache.org/redhat/varnish-4.1.el7.rpm \
	&& yum -y install varnish \
	&& yum clean all

RUN sed -i 's/^\(\[supervisord\]\)$/\1\nnodaemon=true/' /etc/supervisord.conf

ADD https://releases.hashicorp.com/consul-template/${CONSUL_TEMPLATE_VERSION}/consul-template_${CONSUL_TEMPLATE_VERSION}_linux_amd64.zip /tmp
RUN unzip /tmp/consul-template_${CONSUL_TEMPLATE_VERSION}_linux_amd64.zip -d /usr/local/bin && rm /tmp/consul-template_${CONSUL_TEMPLATE_VERSION}_linux_amd64.zip

COPY supervisord.conf /etc/supervisord.d/varnish.conf
COPY varnish-default.ctmpl /tmp/varnish-default.ctmpl

EXPOSE 80
EXPOSE 6082

CMD ["supervisord", "-c", "/etc/supervisord.conf"]
