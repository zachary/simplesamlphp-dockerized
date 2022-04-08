FROM rockylinux/rockylinux:8.4 as download_ssp

ARG SIMPLE_SAML_PHP_VERSION=1.19.6
ARG SIMPLE_SAML_PHP_HASH=834bb4a89d63d7498e77cceb49e01b919d1c0a6a3d38a992f905810dad424b7c

RUN dnf install -y wget \
    && ssp_version=$SIMPLE_SAML_PHP_VERSION; \
           ssp_hash=$SIMPLE_SAML_PHP_HASH; \
           wget https://github.com/simplesamlphp/simplesamlphp/releases/download/v$ssp_version/simplesamlphp-$ssp_version.tar.gz \
    && echo "$ssp_hash  simplesamlphp-$ssp_version.tar.gz" | sha256sum -c - \
    && cd /var \
    && tar xzf /simplesamlphp-$ssp_version.tar.gz \
    && mv simplesamlphp-$ssp_version simplesamlphp

FROM rockylinux/rockylinux:8.4

LABEL maintainer="Unicon, Inc."

ARG PHP_VERSION=7.4.19
ARG HTTPD_VERSION=2.4.37

COPY --from=download_ssp /var/simplesamlphp /var/simplesamlphp

RUN dnf module enable -y php:7.4 \
    && dnf install -y httpd-$HTTPD_VERSION php-$PHP_VERSION \
    && dnf clean all \
    && rm -rf /var/cache/yum

RUN echo $'\nSetEnv SIMPLESAMLPHP_CONFIG_DIR /var/simplesamlphp/config\nAlias /simplesaml /var/simplesamlphp/www\n \
<Directory /var/simplesamlphp/www>\n \
    Require all granted\n \
</Directory>\n' \
       >> /etc/httpd/conf/httpd.conf

COPY httpd-foreground /usr/local/bin/

EXPOSE 80 443

CMD ["httpd-foreground"]
