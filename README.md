## Important Note for 2.2.2+

Starting with the 2.2.2 image, only the bare minimum requirements to run are being included in the base image. The
following (and their dependencies) will need to be installed in a custom image if needed:

* wget
* mod_ssl
* php-ldap
* php-memcache
* php-pear

Also not included is the remirepo RPM repository.

## Overview
This Docker image contains a deployed SimpleSAMLphp IdP/SP based on PHP 8.3 running on Apache HTTP Server 2.4 on the latest rockylinux 9.3 base. This image is a base image and should be used to set the content and configuration with local changes. It is suitable for use as a standalone IdP application or as a base to deploy another PHP application that will be protected by the service provider module.

SimpleSAMLphp is verified using cryptographic hashes obtained from the vendor and stored in the Dockerfile directly.

## Tags
It is recommended that only the highest version tag is used as each previous tag/version is generally associated to fixes of the SimpleSAMLphp application.

## Creating a SimpleSAMLphp Configuration
Image adopters should follow the SimpleSAMLphp documentation (https://simplesamlphp.org/docs/stable/) to configure the IdP/SP and/or other features. Include other directories that one would often customized, such as the images, css, and application files themselves. 

## Using the Image
