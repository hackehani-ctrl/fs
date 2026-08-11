FROM kalilinux/kali-rolling

ENV DEBIAN_FRONTEND=noninteractive
ENV DISPLAY=:1
ENV HOME=/root

RUN apt-get update && \
    apt-get install -y --no-install-recommends \
        kali-desktop-xfce \
        kali-linux-large \
        tigervnc-standalone-server \
        tigervnc-tools \
        novnc \
        websockify \
        dbus-x11 \
        dbus \
        sudo \
        curl \
        wget \
        git \
        nano \
        vim \
        ca-certificates \
        procps \
        iproute2 \
        iputils-ping \
        net-tools \
        psmisc \
        htop \
        lsof \
        unzip \
        zip \
        tar \
        gzip \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*

RUN mkdir -p /root/.vnc

RUN cat > /root/.vnc/xstartup <<'EOF'
#!/bin/sh

unset SESSION_MANAGER
unset DBUS_SESSION_BUS_ADDRESS

export DISPLAY=:1
export XDG_CURRENT_DESKTOP=XFCE
export XDG_SESSION_DESKTOP=xfce

exec startxfce4
EOF

RUN chmod +x /root/.vnc/xstartup

RUN cat > /root/.vnc/config <<'EOF'
geometry=1280x800
depth=24
localhost=no
SecurityTypes=None
EOF

RUN cat > /usr/local/bin/start-kali.sh <<'EOF'
#!/bin/bash

set -e

export DISPLAY=:1
export HOME=/root

echo "======================================"
echo " Kali Linux XFCE"
echo " Starting TigerVNC..."
echo "======================================"

rm -f /tmp/.X1-lock
rm -f /tmp/.X11-unix/X1

vncserver :1 \
    -geometry 1280x800 \
    -depth 24 \
    -localhost no \
    -SecurityTypes None

echo "TigerVNC started on 5901"

PORT="${PORT:-6080}"

echo "Starting noVNC on ${PORT}"

exec websockify \
    --web=/usr/share/novnc \
    0.0.0.0:${PORT} \
    127.0.0.1:5901
EOF

RUN chmod +x /usr/local/bin/start-kali.sh

EXPOSE 6080

CMD ["/usr/local/bin/start-kali.sh"]
