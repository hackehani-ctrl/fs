FROM kalilinux/kali-rolling

ENV DEBIAN_FRONTEND=noninteractive
ENV DISPLAY=:1
ENV HOME=/root

# تثبيت الحزم الأساسية
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
        xvfb \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*

# إعداد VNC
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
localhost=yes
SecurityTypes=None
EOF

# سكريبت التشغيل الرئيسي
RUN cat > /usr/local/bin/start-kali.sh <<'EOF'
#!/bin/bash
set -e

export DISPLAY=:1
export HOME=/root

# منفذ Railway الديناميكي
PORT="${PORT:-6080}"

echo "======================================"
echo " Kali Linux XFCE on Railway"
echo " PORT: ${PORT}"
echo "======================================"

# تنظيف القفل السابق
rm -f /tmp/.X1-lock
rm -f /tmp/.X11-unix/X1

# تشغيل VNC على localhost فقط (الأمان)
vncserver :1 \
    -geometry 1280x800 \
    -depth 24 \
    -localhost yes \
    -SecurityTypes None \
    -xstartup /root/.vnc/xstartup

echo "TigerVNC started on localhost:5901"

# تشغيل noVNC + websockify على 0.0.0.0:${PORT}
# هذا يفتح الوصول من الإنترنت عبر Railway
echo "Starting noVNC on 0.0.0.0:${PORT}"

exec websockify \
    --web=/usr/share/novnc \
    --cert=none \
    0.0.0.0:${PORT} \
    127.0.0.1:5901
EOF

RUN chmod +x /usr/local/bin/start-kali.sh

# Railway يكشف تلقائياً عن PORT من متغير البيئة
# لا حاجة لـ EXPOSE محدد لكن نضعه للتوثيق
EXPOSE 6080

# استخدام shell form للسماح بتوسيع ${PORT}
CMD /usr/local/bin/start-kali.sh
