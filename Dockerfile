FROM centos:centos7

MAINTAINER Unicon, Inc.

RUN yum -y install epel-release \
    && yum -y update \
    && yum -y install httpd mod_ssl php php-mcrypt php-pear php-xml php-pdo wget \
    && yum -y clean all

RUN ssp_version=1.14.3; \
    ssp_hash=99e030d744ca4d8cd5033ef0da51d9f825ae05302045664fd49a2bae4e057a21; \   
    wget https://simplesamlphp.org/res/downloads/simplesamlphp-$ssp_version.tar.gz \
    && echo "$ssp_hash  simplesamlphp-$ssp_version.tar.gz" | sha256sum -c - \
	&& cd /var \
	&& tar xzf /simplesamlphp-$ssp_version.tar.gz \
    && mv simplesamlphp-$ssp_version simplesamlphp \
    && rm /simplesamlphp-$ssp_version.tar.gz

RUN echo $'\nSetEnv SIMPLESAMLPHP_CONFIG_DIR /var/simplesamlphp/config\nAlias /simplesaml /var/simplesamlphp/www\n \
<Directory /var/simplesamlphp/www>\n \
    Require all granted\n \
</Directory>\n' \
       >> /etc/httpd/conf/httpd.conf

COPY httpd-foreground /usr/local/bin/

EXPOSE 80 443

CMD ["httpd-foreground"]