FROM kiicorp/base:centos-7
MAINTAINER Susumu

ENV CONSUL_TEMPLATE_VERSION 0.14.0
ENV CONSUL_URL consul:8500
ENV VARNISH_PORT 80
ENV VARNISH_STORAGE_BACKEND malloc,100M
ENV VARNISHNCSA_LOGFORMAT %h %l %u %t "%r" %s %b "%{Referer}i" "%{User-agent}i"

ADD https://releases.hashicorp.com/consul-template/${CONSUL_TEMPLATE_VERSION}/consul-template_${CONSUL_TEMPLATE_VERSION}_linux_amd64.zip /tmp
RUN yum -y install supervisor \
	&& rpm --import https://repo.varnish-cache.org//GPG-key.txt \
	&& rpm -Uvh https://repo.varnish-cache.org/redhat/varnish-4.1.el7.rpm \
	&& yum -y install varnish \
	&& yum clean all \
	&& unzip /tmp/consul-template_${CONSUL_TEMPLATE_VERSION}_linux_amd64.zip -d /usr/local/bin \
	&& rm /tmp/consul-template_${CONSUL_TEMPLATE_VERSION}_linux_amd64.zip \
	&& sed -i 's/nodaemon=false/nodaemon=true/g' /etc/supervisord.conf
 
COPY supervisor/varnish.ini /etc/supervisord.d/varnish.ini
COPY supervisor/consul-template.ini /etc/supervisord.d/consul-template.ini

COPY varnish-default.ctmpl /etc/varnish/consul.ctmpl

EXPOSE 80
EXPOSE 6082

CMD ["supervisord", "-c", "/etc/supervisord.conf"]
