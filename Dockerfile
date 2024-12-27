FROM ghcr.io/linuxserver/sonarr
LABEL maintainer="mdhiggins <mdhiggins23@gmail.com>"

ENV SMA_PATH /usr/local/sma
ENV SMA_RS Sonarr
ENV SMA_UPDATE false
ENV SMA_FFMPEG_PATH ffmpeg
ENV SMA_FFPROBE_PATH ffprobe
ENV SMA_FFMPEG_URL https://johnvansickle.com/ffmpeg/releases/ffmpeg-release-amd64-static.tar.xz

# get python3 and git, and install python libraries
RUN \
  apk update && \
  apk add --no-cache \
    git \
    wget \
    python3 \
    py3-pip \
    py3-virtualenv && \
# make directory
  mkdir ${SMA_PATH} && \
# download repo
  git config --global --add safe.directory ${SMA_PATH} && \
  git clone https://github.com/mdhiggins/sickbeard_mp4_automator.git ${SMA_PATH} && \
# install pip, venv, and set up a virtual self contained python environment
  python3 -m virtualenv ${SMA_PATH}/venv && \
  ${SMA_PATH}/venv/bin/pip install -r ${SMA_PATH}/setup/requirements.txt && \
# cleanup
  apk del --purge && \
  rm -rf \
    /root/.cache \
    /tmp/*

EXPOSE 8989

VOLUME /config
VOLUME /usr/local/sma/config

# update.py sets FFMPEG/FFPROBE paths, updates API key and Sonarr/Radarr settings in autoProcess.ini
COPY extras/ ${SMA_PATH}/
COPY root/ /
RUN chmod +x ${SMA_PATH}/postSonarr.sh
