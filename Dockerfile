FROM python:stretch

VOLUME /etc/pretix
VOLUME /data
VOLUME /static

RUN apt-get update
RUN apt-get install -y git libxml2-dev libxslt1-dev python-dev python-virtualenv locales \
    libffi-dev build-essential python3-dev zlib1g-dev libssl-dev gettext libpq-dev \
    default-libmysqlclient-dev libjpeg-dev sudo

RUN apt-get clean
RUN rm -rf /var/lib/apt/lists/* && \
    dpkg-reconfigure locales && \
	locale-gen C.UTF-8 && \
	/usr/sbin/update-locale LANG=C.UTF-8

ENV LC_ALL=C.UTF-8
ENV DJANGO_SETTINGS_MODULE=production_settings

ARG BRANCH="release/3.6.x"
WORKDIR /
RUN git clone --branch $BRANCH --depth 1 https://github.com/pretix/pretix.git \
    && cd /pretix/src \
    && pip3 install -U pip wheel setuptools uwsgi \
    && pip3 install -r requirements.txt -r requirements/redis.txt

WORKDIR /pretix/src
RUN mkdir -p data

COPY ./pretix/production_settings.py /pretix/src/
COPY ./pretix/uwsgi.ini /pretix/src/
COPY ./pretix/docker-entrypoint.sh /pretix/src/
