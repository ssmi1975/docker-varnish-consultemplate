FROM ubuntu:14.04
MAINTAINER  CREATIVE AREA

ENV DEBIAN_FRONTEND noninteractive
ENV CONSUL_URL consul:8500
ENV VARNISH_PORT 80
ENV VARNISH_STORAGE_BACKEND malloc,100M
ENV VARNISHNCSA_LOGFORMAT %h %l %u %t "%r" %s %b "%{Referer}i" "%{User-agent}i"

RUN apt-get -qq update && apt-get install -y \
    curl \
    apt-transport-https \
    supervisor

RUN sed -i 's/^\(\[supervisord\]\)$/\1\nnodaemon=true/' /etc/supervisor/supervisord.conf

RUN \
    curl -sL https://repo.varnish-cache.org/GPG-key.txt | apt-key add - && \
    echo "deb https://repo.varnish-cache.org/ubuntu/ trusty varnish-4.0" >> /etc/apt/sources.list.d/varnish-cache.list && \
    apt-get -qq update && \
    apt-get install -y varnish

RUN apt-get install -y unzip
ADD https://releases.hashicorp.com/consul-template/0.14.0/consul-template_0.14.0_linux_amd64.zip /usr/local/src/
RUN unzip /usr/local/src/consul-template_0.14.0_linux_amd64.zip -d /usr/local/bin

COPY supervisord.conf /etc/supervisor/conf.d/supervisord.conf
COPY varnish-default.ctmpl /tmp/varnish-default.ctmpl

EXPOSE 80
EXPOSE 6082

CMD ["supervisord", "-c", "/etc/supervisor/supervisord.conf"]
