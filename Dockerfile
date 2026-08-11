FROM --platform=linux/amd64 ubuntu:22.04

ARG DEBIAN_FRONTEND=noninteractive
ENV DEBIAN_FRONTEND=${DEBIAN_FRONTEND} VNC_PASS=

# Install prerequisites needed for add-apt-repository and basic tooling
RUN apt-get update && \
    apt-get install -y --no-install-recommends \
      software-properties-common ca-certificates gnupg2 dirmngr lsb-release wget curl \
    && rm -rf /var/lib/apt/lists/*

# Add Mozilla PPA (best-effort) and install desktop + VNC/noVNC + supervisor
RUN add-apt-repository ppa:mozillateam/ppa -y || true
RUN apt-get update && \
    apt-get install -y --no-install-recommends \
      xfce4 xfce4-goodies \
      tigervnc-standalone-server tigervnc-common \
      novnc websockify \
      dbus-x11 x11-utils x11-xserver-utils x11-apps \
      firefox xubuntu-icon-theme \
      sudo xterm vim net-tools curl wget git tzdata \
      supervisor \
    && apt-get clean && rm -rf /var/lib/apt/lists/*

# Copy supervisor config and startup scripts (added on branch)
COPY /etc/supervisor/conf.d/supervisord.conf /etc/supervisor/conf.d/supervisord.conf
COPY start-desktop.sh /usr/local/bin/start-desktop.sh
COPY entrypoint.sh /usr/local/bin/entrypoint.sh
RUN chmod +x /usr/local/bin/start-desktop.sh /usr/local/bin/entrypoint.sh || true

# Ensure Xauthority exists
RUN touch /root/.Xauthority && mkdir -p /root/.vnc

EXPOSE 5901
EXPOSE 6080
VOLUME ["/root/.vnc"]

ENTRYPOINT ["/usr/local/bin/entrypoint.sh"]
CMD ["/usr/bin/supervisord", "-c", "/etc/supervisor/conf.d/supervisord.conf"]
