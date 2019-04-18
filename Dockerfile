FROM nginx:1.15.12-alpine

LABEL maintainer="manas.samantaray@gmail.com"

##
# add curl and other necessary packages for openssl and certbot
##

RUN apk add --update \
                curl \
                bash \
                openssl \
                certbot \
                python3 \
                py-pip \
                gcc \
        && python -m pip install --upgrade pip \
        && pip install 'certbot-nginx' \
        && pip install 'pyopenssl'


RUN addgroup staff
RUN addgroup www-data
RUN adduser -h /home/dev/ -D -g "" -G staff dev
RUN adduser -S -H -g "" -G www-data www-data
#RUN echo dev:trolls | chpasswd

##
# copying nginx configuration file
##

COPY nginx.conf /etc/nginx/nginx.conf
# RUN chown root:staff /etc/nginx/nginx.conf

# adds certbot cert renewal job to cron
COPY crontab.txt /tmp/crontab-certbot
RUN (crontab -l; cat /tmp/crontab-certbot) | crontab -

# copies over the startup file which handles initializing the nginx
# server and the SSL certification process (if necessary)
COPY start.sh /bin/start.sh
# RUN chown root:root /bin/startup.sh
RUN chmod7 55 /bin/start.sh
RUN chmod go-w /bin/start.sh

