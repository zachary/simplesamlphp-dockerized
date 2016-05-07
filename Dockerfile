FROM centos:centos7

MAINTAINER Unicon, Inc.

RUN yum -y install epel-release \
    && yum -y update \
    && yum -y install httpd mod_ssl php php-mcrypt php-pear php-xml php-pdo wget \
    && yum -y clean all

RUN ssp_version=1.14.2; \
    ssp_hash=19b849065cdc8b96d74570b2ef91a08e72d0a4c0d9c30fa9526163ff6684c83e; \   
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