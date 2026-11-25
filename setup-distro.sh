cat << 'EOF' > /root/setup-distro.sh
#!/bin/bash
set -e

# ==========================================
# KONFIGURASI KELOMPOK 1 (UBAH SESUAI TIM)
# ==========================================
DISTRO_NAME="NetLabOS"
DISTRO_DESC="NetLabOS - Distro Lab Jaringan Kelompok 1"
TIMEZONE="Asia/Makassar"

echo "=== [1/7] Update Repositori ==="
apt update
apt-add-repository -y universe
apt-add-repository -y multiverse
apt update

echo "=== [2/7] Install XFCE, LightDM, & Hapus GNOME ==="
DEBIAN_FRONTEND=noninteractive apt install -y \
  xfce4 xfce4-goodies lightdm lightdm-gtk-greeter \
  xfce4-terminal network-manager-gnome

echo "lightdm shared/default-x-display-manager select lightdm" | debconf-set-selections
echo "/usr/sbin/lightdm" > /etc/X11/default-display-manager
dpkg-reconfigure -f noninteractive lightdm

apt purge -y ubuntu-desktop gnome-shell gdm3 \
  libreoffice* rhythmbox* thunderbird* \
  aisleriot gnome-mahjongg gnome-mines gnome-sudoku
apt autoremove -y

apt install -y ubiquity ubiquity-frontend-gtk casper

echo "=== [3/7] Konfigurasi Autologin Live USB ==="
mkdir -p /etc/lightdm/lightdm.conf.d
cat << 'EOC' > /etc/lightdm/lightdm.conf.d/50-xfce-default.conf
[Seat:*]
user-session=xfce
greeter-session=lightdm-gtk-greeter
EOC

cat << 'EOC' > /etc/lightdm/lightdm.conf.d/50-live-autologin.conf
[Seat:*]
autologin-guest=false
autologin-user=ubuntu
autologin-user-timeout=0
autologin-session=xfce
EOC

echo "=== [4/7] Pasang Wallpaper Desktop & Login ==="
mkdir -p /usr/share/backgrounds/distro-custom
if [ -f /root/wallpaper-distro.jpg ]; then
  mv /root/wallpaper-distro.jpg /usr/share/backgrounds/distro-custom/wallpaper-distro.jpg
fi
chmod 755 /usr/share/backgrounds/distro-custom
chmod 644 /usr/share/backgrounds/distro-custom/wallpaper-distro.jpg

ln -sf /usr/share/backgrounds/distro-custom/wallpaper-distro.jpg /usr/share/backgrounds/xfce/xfce-verticals.png
ln -sf /usr/share/backgrounds/distro-custom/wallpaper-distro.jpg /usr/share/backgrounds/xfce/xfce-shapes.svg

mkdir -p /etc/skel/.config/xfce4/xfconf/xfce-perchannel-xml
cat << 'EOC' > /etc/skel/.config/xfce4/xfconf/xfce-perchannel-xml/xfce4-desktop.xml
<?xml version="1.0" encoding="UTF-8"?>
<channel name="xfce4-desktop" version="1.0">
  <property name="backdrop" type="empty">
    <property name="screen0" type="empty">
      <property name="monitorVirtual1" type="empty">
        <property name="workspace0" type="empty">
          <property name="last-image" type="string" value="/usr/share/backgrounds/distro-custom/wallpaper-distro.jpg"/>
          <property name="image-style" type="int" value="5"/>
        </property>
      </property>
      <property name="monitor0" type="empty">
        <property name="workspace0" type="empty">
          <property name="last-image" type="string" value="/usr/share/backgrounds/distro-custom/wallpaper-distro.jpg"/>
          <property name="image-style" type="int" value="5"/>
        </property>
      </property>
    </property>
  </property>
</channel>
EOC

cat << 'EOC' > /etc/lightdm/lightdm-gtk-greeter.conf
[greeter]
background=/usr/share/backgrounds/distro-custom/wallpaper-distro.jpg
theme-name=Greybird
icon-theme-name=elementary-xfce-dark
EOC

echo "=== [5/7] Pasang Kernel & Boot Splash Plymouth ==="
DEBIAN_FRONTEND=noninteractive apt install -y plymouth plymouth-themes linux-image-generic linux-headers-generic

mkdir -p /usr/share/plymouth/themes/distro-splash
if [ -f /root/logo-distro.png ]; then
  mv /root/logo-distro.png /usr/share/plymouth/themes/distro-splash/logo-distro.png
fi

cat << 'EOC' > /usr/share/plymouth/themes/distro-splash/distro-splash.plymouth
[Plymouth Theme]
Name=Distro Custom Splash
Description=Splash screen kustom tugas proyek Sistem Operasi
ModuleName=script

[script]
ImageDir=/usr/share/plymouth/themes/distro-splash
ScriptFile=/usr/share/plymouth/themes/distro-splash/distro-splash.script
EOC

cat << 'EOC' > /usr/share/plymouth/themes/distro-splash/distro-splash.script
Window.SetBackgroundTopColor(0.08, 0.10, 0.14);
Window.SetBackgroundBottomColor(0.05, 0.06, 0.09);

logo.image = Image("logo-distro.png");
logo.sprite = Sprite(logo.image);
logo.sprite.SetX(Window.GetWidth() / 2 - logo.image.GetWidth() / 2);
logo.sprite.SetY(Window.GetHeight() / 2 - logo.image.GetHeight() / 2);
logo.sprite.SetOpacity(1);
EOC

update-alternatives --install \
  /usr/share/plymouth/themes/default.plymouth default.plymouth \
  /usr/share/plymouth/themes/distro-splash/distro-splash.plymouth 200
update-alternatives --set default.plymouth \
  /usr/share/plymouth/themes/distro-splash/distro-splash.plymouth
update-initramfs -u -k all

echo "=== [6/7] Install 10 Paket Lab Jaringan ==="
DEBIAN_FRONTEND=noninteractive apt install -y \
  wireshark nmap traceroute net-tools iperf3 \
  tcpdump curl whois dnsutils mtr

echo "=== [7/7] Branding OS, Zona Waktu, & First-Login Script ==="
sed -i "s/^PRETTY_NAME=.*/PRETTY_NAME=\"$DISTRO_DESC\"/" /etc/os-release
sed -i "s/^NAME=.*/NAME=\"$DISTRO_NAME\"/" /etc/os-release
sed -i "s/^DISTRIB_DESCRIPTION=.*/DISTRIB_DESCRIPTION=\"$DISTRO_DESC\"/" /etc/lsb-release

ln -sf /usr/share/zoneinfo/$TIMEZONE /etc/localtime
echo "$TIMEZONE" > /etc/timezone
locale-gen en_US.UTF-8 id_ID.UTF-8
update-locale LANG=en_US.UTF-8

mkdir -p /usr/local/bin /etc/skel/.config/autostart
cat << EOC > /usr/local/bin/first-login.sh
#!/bin/bash
FLAG="\$HOME/.first_login_done"
if [ ! -f "\$FLAG" ]; then
  xfce4-terminal --hold -e "bash -c 'echo Selamat datang di $DISTRO_NAME!; uname -a; echo Konfigurasi awal berhasil dijalankan.'"
  touch "\$FLAG"
fi
EOC
chmod +x /usr/local/bin/first-login.sh

cat << 'EOC' > /etc/skel/.config/autostart/first-login.desktop
[Desktop Entry]
Type=Application
Name=First Login Setup
Exec=/usr/local/bin/first-login.sh
X-GNOME-Autostart-enabled=true
EOC

echo "=== Bersihkan Cache APT ==="
apt clean
rm -rf /tmp/* /var/lib/apt/lists/*

echo "SELESAI! Silakan klik Next di Cubic dan pilih kernel 5.15.0-xxx di tab Kernel."
EOF

chmod +x /root/setup-distro.sh
/root/setup-distro.sh
