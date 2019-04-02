
#### Author: Aysad Kozanoglu
##### Email: aysadx@gmail.com

my one-liner auto installer scripts for debian Jessie (jessie LTS until 2020) (and derivates like ubuntu)

##### MariaDB singler Server installation
[source](https://gist.github.com/AysadKozanoglu/d485de4d7b6492cb0c478c098b4c63c6#file-mariadb_debian_jessie_install-sh)
```
wget -O - https://git.io/fpuj6 | bash
```

##### nginx threads,iao, stream, ssl compile installation
[source](https://gist.github.com/AysadKozanoglu/8f95343bb5e4e97ab09461ef92dd3124#file-nginx_compile_install-sh)
```
wget -O - https://git.io/fpujF | bash
```

##### php7.2 installation (execute two times)
[source](https://gist.github.com/AysadKozanoglu/52aa3439f87703edaa2163795896b526#file-php7-install-debian_jessie)
```
wget -O - https://git.io/fhxNt | bash
```
##### KVM CLoud with WEB Gui installation
[source](https://github.com/AysadKozanoglu/webvirtmgr/wiki/Install-WebVirtMgr-KVM-Cloud---Easy-auto-installer)
```
wget -O part1.sh https://git.io/fpAJH && sh part1.sh
wget -O part2.sh https://git.io/fpAJA && sh part2.sh
/var/www/webvirtmgr/manage.py syncdb
/var/www/webvirtmgr/manage.py collectstatic
chown -R www-data:www-data /var/www/webvirtmgr
sudo  -u www-data bash -c "/usr/bin/python /var/www/webvirtmgr/console/webvirtmgr-console >> /var/www/webvirtmgr/webService.log 2>&1 &" 
sudo  -u www-data bash -c "/usr/bin/python /var/www/webvirtmgr/manage.py runserver 127.0.0.1:8000 >> /var/www/webvirtmgr/webService.log 2>&1 & "
```
##### XEN Orchestra Community Edition from source installation
[source](https://raw.githubusercontent.com/AysadKozanoglu/Auto-installer-xen-orchestra-source/master/xo-auto-installer.sh)
```
wget -O -  https://git.io/fhIr6 | bash
```

