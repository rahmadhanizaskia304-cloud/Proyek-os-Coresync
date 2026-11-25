# Tahap 1 — Distro Linux Kustom: Coresynch (Topik 1: Lab Jaringan)
## Identitas Distro
- *Nama Distro:* Coresynch
- *Basis Sistem:* Ubuntu 22.04.5 LTS (Jammy Jellyfish)
- *Desktop Environment:* XFCE4 + LightDM
## Daftar 10 Paket Jaringan & Alasan Pemilihan
1. wireshark — Analisis dan inspeksi paket jaringan secara mendalam berbasis GUI.
2. nmap — Pemetaan jaringan, deteksi host aktif, dan pemindaian port terbuka.
3. tcpdump — Packet sniffer ringan berbasis terminal untuk analisis cepat.
4. traceroute — Melacak jalur (hop) yang dilalui paket data menuju server tujuan.
5. mtr — Diagnostik latensi dan packet loss secara real-time.
6. iperf3 — Mengukur kecepatan dan performa bandwidth jaringan antar perangkat.
7. net-tools — Utilitas jaringan klasik (ifconfig, netstat, route, arp).
8. dnsutils — Pengujian dan pemecahan masalah resolusi DNS (dig, nslookup).
9. curl — Pengujian konektivitas dan respons protokol HTTP/HTTPS.
10. whois — Pengecekan informasi kepemilikan domain, blok IP, dan ASN.

## Paket Bawaan yang Dihapus (apt purge)
- ubuntu-desktop, gnome-shell, gdm3 (diganti XFCE & LightDM agar hemat RAM)
- libreoffice*, thunderbird*, rhythmbox* (mengurangi ukuran ISO)
- aisleriot, gnome-mahjongg, gnome-mines, gnome-sudoku (tidak relevan dengan tema)

## Cara Reproduksi Build
1. Ekstrak ISO induk Ubuntu 22.04.5 menggunakan Cubic.
2. Pasang XFCE4, LightDM, Plymouth, dan 10 paket jaringan, lalu hapus paket bawaan di atas.
3. Salin konfigurasi pada folder assets/ dan configs/, perbarui initramfs (update-initramfs -u -k all), pilih kernel 5.15.0-xxx pada tab Kernel Cubic, lalu Generate ISO.
