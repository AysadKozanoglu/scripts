
# author : Aysad Kozanoglu
#
# part of cloud-init initiliasion process 
# installation of docker
# codeslines can also be used without cloud-init as script

# Install 
# wget -qO- "https://raw.githubusercontent.com/AysadKozanoglu/scripts/master/docker-install-buster.sh" | bash 


export PATH=$PATH":/usr/local/sbin:/usr/sbin:/sbin"

mkdir -p  /sources/old > /dev/null 2>&1

# the order of packages must be hold below ##
# the order of packages is neccassary while installing (depencies)#

echo "containerd.io_1.6.9-1_amd64.deb
docker-ce_20.10.19~3-0~debian-buster_amd64.deb
docker-ce-cli_20.10.21~3-0~debian-buster_amd64.deb
docker-compose-plugin_2.12.0~debian-buster_amd64.deb" > /sources/docker_packages.txt

cat /sources/docker_packages.txt | while read DOCKERPACKAGE; do
wget -O /sources/$DOCKERPACKAGE https://download.docker.com/linux/debian/dists/buster/pool/stable/amd64/$DOCKERPACKAGE && dpkg -i /sources/$DOCKERPACKAGE || echo "Error while download or install package $DOCKERPACKAGE";
done

groupadd docker 
systemctl enable docker
systemctl start docker

mv /sources/*.deb /sources/old/
