# Each instruction in this file generates a new layer that gets pushed to your local image cache
# Lines preceeded by # are regarded as comments and ignored

# The line below states we will base our new image on the Latest Official Ubuntu 
FROM ubuntu:20.04
# labels
LABEL version="1.0.0"

# Pre-configure timezone to stop hang during build
ENV TZ=Europe/Brussels
RUN ln -snf /usr/share/zoneinfo/$TZ /etc/localtime && echo $TZ > /etc/timezone

# Update the image to the latest packages
RUN	apt-get update && apt-get upgrade -y \
	&& apt-get clean -y

# Install Apache2 and Perl, enable cgid and disable the default site
RUN apt-get install -y \
		apache2 \
		perl \
		libcgi-pm-perl \
		libdbi-perl \
		libdbd-mysql-perl \
	&& a2enmod cgid \
	&& a2dissite 000-default \
	&& rm /var/www/html/index.html
	
# Copy shipping-challenge site config & app folder contents to container
COPY ./apache2_config/shipping-challenge.conf /etc/apache2/sites-enabled/shipping-challenge.conf
COPY ./apache2_app/ /var/www/html/

RUN chmod +x /var/www/html/index.pl \
            /var/www/html/db_seed.pl \
            /var/www/html/db_update_name.pl \
	&& service apache2 restart

# Expose port 80
EXPOSE 80

# run Apache2 in foreground mode
CMD ["apachectl", "-D", "FOREGROUND"]