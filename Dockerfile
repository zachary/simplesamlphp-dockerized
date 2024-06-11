FROM rockylinux/rockylinux:9.3 as download_ssp

ARG SIMPLE_SAML_PHP_VERSION=2.2.2
ARG SIMPLE_SAML_PHP_HASH=4aca4af58fcf450099f4729a5abe4a831d5dc8b5663d6147d3da069319f23107

RUN dnf install -y wget \
    && ssp_version=$SIMPLE_SAML_PHP_VERSION; \
           ssp_hash=$SIMPLE_SAML_PHP_HASH; \
           wget https://github.com/simplesamlphp/simplesamlphp/releases/download/v$ssp_version/simplesamlphp-$ssp_version-full.tar.gz \
    && echo "$ssp_hash  simplesamlphp-$ssp_version-full.tar.gz" | sha256sum -c - \
    && cd /var \
    && tar xzf /simplesamlphp-$ssp_version-full.tar.gz \
    && mv simplesamlphp-$ssp_version simplesamlphp

FROM rockylinux/rockylinux:9.3

LABEL maintainer="Zachary"

ARG PHP_VERSION=8.3.7
ARG HTTPD_VERSION=2.4.57

COPY --from=download_ssp /var/simplesamlphp /var/simplesamlphp

RUN dnf install -y https://dl.fedoraproject.org/pub/epel/epel-release-latest-8.noarch.rpm \
    && dnf -y install https://rpms.remirepo.net/enterprise/remi-release-9.2.rpm \
    && dnf -y install yum-utils \
    && dnf module reset php \
    && dnf module install -y php:remi-8.3 \
    && dnf -y update

RUN dnf install -y httpd-$HTTPD_VERSION php-$PHP_VERSION \
    && dnf install -y git php-ldap php-zip unzip php-mysql php-pgsql vim \
    && dnf clean all \
    && rm -rf /var/cache/yum

RUN echo $'\nSetEnv SIMPLESAMLPHP_CONFIG_DIR /var/simplesamlphp/config\nAlias /simplesaml /var/simplesamlphp/public\n \
<Directory /var/simplesamlphp/public>\n \
    Require all granted\n \
</Directory>\n' \
       >> /etc/httpd/conf/httpd.conf

COPY simplesamlphp/saml-autoconfig.php /var/simplesamlphp/
COPY simplesamlphp/config/config.php /var/simplesamlphp/config/
COPY simplesamlphp/config/authsources.php /var/simplesamlphp/config/
COPY simplesamlphp/metadata/saml20-idp-remote.php /var/simplesamlphp/metadata/
COPY --from=composer:latest /usr/bin/composer /usr/local/bin/composer
RUN cd /var/simplesamlphp && composer install \
    && chmod -R 777 /var/cache
COPY httpd-foreground /usr/local/bin/

EXPOSE 80 443

CMD ["httpd-foreground"]
