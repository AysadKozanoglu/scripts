# https://vestacp.com/install/

curl -O http://vestacp.com/pub/vst-install.sh
bash vst-install.sh --nginx yes --phpfpm yes --apache no --named yes --remi yes --vsftpd no --proftpd yes --iptables yes --fail2ban yes --quota no --exim yes --dovecot yes --spamassassin yes --clamav no --softaculous no --mysql yes --postgresql no --hostname <DOMAIN> --email <EMAIL> --password !!PASSWORD!!
