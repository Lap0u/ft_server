# **************************************************************************** #
#                                                                              #
#                                                         :::      ::::::::    #
#    Dockerfile                                         :+:      :+:    :+:    #
#                                                     +:+ +:+         +:+      #
#    By: cbeaurai <cbeaurai@42.student.fr>          +#+  +:+       +#+         #
#                                                 +#+#+#+#+#+   +#+            #
#    Created: 2021/01/11 17:32:01 by cbeaurai          #+#    #+#              #
#    Updated: 2021/01/14 01:52:07 by user42           ###   ########.fr        #
#                                                                              #
# **************************************************************************** #

FROM debian:buster

LABEL maintainer="cbeaurai  cbeaurai@student.42.fr"

RUN apt-get update
RUN apt-get upgrade -y
RUN apt-get install -y nginx
RUN apt-get install -y mariadb-server
RUN apt-get install -y php-fpm php-common php-mbstring php-xmlrpc php-soap php-gd php-xml php-intl php-mysql php-cli php-zip php-curl
RUN apt-get install -y wget
RUN apt-get install -y vim

COPY ./srcs/setup.sh ./tmp/
COPY ./srcs/nginx-conf ./tmp/nginx-conf
COPY ./srcs/phpmyadmin.inc.php ./tmp/phpmyadmin.inc.php
COPY ./srcs/wp-config.php ./tmp/wp-config.php

CMD sh ./tmp/setup.sh

EXPOSE 80 443
