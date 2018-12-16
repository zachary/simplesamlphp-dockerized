FROM centos:centos7

LABEL maintainer="Unicon, Inc."

RUN yum -y install epel-release \
    && yum-config-manager --enable remi-php72 \
    && yum -y update \
    && yum -y install httpd mod_ssl php php-mbstring php-mcrypt php-pdo php-pear php-xml wget \
    && yum -y clean all

RUN ssp_version=1.16.0; \
    ssp_hash=5a50025acb866e46a67f031d829362b13eb9635a963aa4b2f0439b3a885e7abc; \
    wget https://github.com/simplesamlphp/simplesamlphp/releases/download/v$ssp_version/simplesamlphp-$ssp_version.tar.gz \
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
