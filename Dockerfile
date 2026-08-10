# Use explicit amd64 platform with Kali rolling
FROM --platform=linux/amd64 kalilinux/kali-rolling:latest

ARG KALI_METAPACKAGE=kali-linux-default
ENV DEBIAN_FRONTEND=noninteractive

# Install XFCE, VNC/noVNC and utilities
RUN apt-get update -y && \
    apt-get install -y --no-install-recommends \
      $KALI_METAPACKAGE \
      xfce4 xfce4-goodies \
      tigervnc-standalone-server \
      novnc \
      websockify \
      sudo \
      xterm \
      vim \
      net-tools \
      curl wget git tzdata \
      dbus-x11 x11-utils x11-xserver-utils x11-apps \
      software-properties-common \
      firefox-esr \
      xubuntu-icon-theme && \
    apt-get clean && rm -rf /var/lib/apt/lists/*

# Ensure Xauthority exists
RUN touch /root/.Xauthority

EXPOSE 5901
EXPOSE 6080

# Start VNC server, create self-signed cert, run websockify/noVNC
# NOTE: -SecurityTypes None is insecure as requested in the original example
CMD ["bash", "-lc", "vncserver -localhost no -SecurityTypes None -geometry 1024x768 --I-KNOW-THIS-IS-INSECURE && openssl req -new -subj '/C=JP' -x509 -days 365 -nodes -out /root/self.pem -keyout /root/self.pem && websockify -D --web=/usr/share/novnc/ --cert=/root/self.pem 6080 localhost:5901 && tail -f /dev/null"]
