#!/bin/bash

#++++++  CHANGE line 35,36,56 with your own Public SSH KEY, otherwise you would be "hacked",   :)  ++++#

#  author: Aysad Koaznoglu
# version: v0.2
# cloud-init KVM automation 

# downloat all images for cloud-int for your needs to/var/lib/libvirt/images/templates/
# links:
#
# ubuntu 22.0-server
# wget https://cloud-images.ubuntu.com/jammy/current/jammy-server-cloudimg-amd64.img
#
# ubuntu 20.04-server
# wget https://cloud-images.ubuntu.com/releases/focal/release/ubuntu-20.04-server-cloudimg-amd64.img
#
# debian buster 10
# wget http://cloud.debian.org/images/cloud/buster/20220911-1135/debian-10-generic-amd64-20220911-1135.qcow2

apt install cloud-utils whois -y


VMSTORAGEPATH=/mnt/lvmvg01storageraid1
 CLOUDIMGPATH=/var/lib/libvirt/images/templates


# debug
echo $1" "$2
#exit 1


CLOUD_INIT_IMG=$1
       VM_NAME=$2
      USERNAME=suser
      PASSWORD=suser

        if [[ -d "$VMSTORAGEPATH/$VM_NAME" ]];
        then
                echo "VM storage exists:  "$VMSTORAGEPATH/$VM_NAME" FOUND  !!!"
                tree $VMSTORAGEPATH/$VM_NAME
                exit 1
	else
		echo "creating storage path: $VMSTORAGEPATH/$VM_NAME"
		mkdir $VMSTORAGEPATH/$VM_NAME > /dev/null 2>&1
        fi


## cloud init cfg param config
echo "#cloud-config
system_info:
  default_user:
    name: $USERNAME
    home: /home/$USERNAME
    ssh-authorized-keys:
      - ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAACAQDWCf5/aAFk7SvYzmSC1srDSnViiFtxfm8eBBCDZTjU5TMN0FbVG0ClGKnEiTooQJs5TNrQsO0/K0WKxsVlZJ8/B3qAogMYa8/6ScAzY9KFEthFjN2ARzXZ1NZ/+hwotfAKY0k+cZQ2SmZYwf01zLlyrQgZth4Vm1Qc+/gVZxyMgFZAwFMo28Dv87UnhdvC7jxh9MmwPlxx9eRAaGShstLE89fzmp7p0P1t8ck+yYf5zQvfdq0zkdYsRxn4Oy8lvdU5APO08wr6c3Ycsu/YHWWm00T5U5cCR4Y5lm8607/j3tBgJ//gDYNhNo/3te3+zrntDkdCKA1ZmKN7N79oRb4A3H2RZLwcw+vV6n+WxvcYEJhoaIzyhHg4paUwVfxmyApegcfJaLfZietVd4NWydcd4TXac7mvNFVzT2K3Zy0Qr2OhRwtKdFwLdaxMJYojj1Y3sV/zDbCXFqO4iOpmZ3KgfZQNREIguJWvfy+ypSBwIr3Y4wBQ9QQ8k0BKgSuQaMIP5lSZyIf422eNx2rshzKHYJfUlGlFC49p4fZYrx8LmT2qFdzRL0r+oF/uaEj3XsTqg5RzkVRqw6cM6orn+uCI5Y+GoBhxdoKmo0lxIB4m005ajIq2/CK6AqtsTpkuh8diO/g/Jmywq8RiJVBxs0EWzVu+1SfaKeLd6I8pE53vVQ== ghost@local

password: $PASSWORD
chpasswd: { expire: False }
hostname: $VM_NAME

# configure sshd to allow users logging in using password 
# rather than just keys
ssh_pwauth: True

runcmd:
    - [ sh, -c, 'echo $(date) "docker installation" > /var/log/docker-installation.log' ]
#    - [ sh, -c, 'wget -qO- "https://raw.githubusercontent.com/AysadKozanoglu/scripts/master/docker-install-buster.sh" | bash  >> /var/log/docker-installation.log 2>&1' ]
    - [ sh, -c, 'wget -qO- "https://get.docker.com/" | sh >> /var/log/docker-installation.log 2>&1' ]

" | tee $VMSTORAGEPATH/$VM_NAME/cloud-init.cfg
## End of cloud init cfg


if [[ ! -f "$VMSTORAGEPATH/$VM_NAME/cloud-init.cfg" ]]; then
    echo " not found"
    exit 1
fi


function checkparams {
	if [[ ! -f "$CLOUDIMGPATH/$CLOUD_INIT_IMG" ]];
	then
        	echo "IMG FILE "$CLOUDIMGPATH/$CLOUD_INIT_IMG" not found !!!"
		echo "choose one:"
		tree $CLOUDIMGPATH/ | grep -E -i  "\.img|\.qcow"
        	exit 1
	fi

	if [[ ! $CLOUD_INIT_IMG ]]; then
		echo " give a cloud bas image file name see $CLOUDIMGPATH/"
		tree $CLOUDIMGPATH/ | grep -E -i  "\.img|\.qcow"
		exit 1
	fi
	
	
	if [[ ! $VM_NAME ]]; then
		echo "give new vm name"
		exit 1
	fi
}


function build {

	qemu-img convert $CLOUDIMGPATH/$CLOUD_INIT_IMG $VMSTORAGEPATH/$VM_NAME/root-disk.qcow2
	qemu-img resize $VMSTORAGEPATH/$VM_NAME/root-disk.qcow2 10G
	cloud-localds $VMSTORAGEPATH/$VM_NAME/cloud-init.iso $VMSTORAGEPATH/$VM_NAME/cloud-init.cfg
	virt-install \
	  --name $VM_NAME \
	  --memory 1024 \
	  --disk $VMSTORAGEPATH/$VM_NAME/root-disk.qcow2,device=disk,bus=virtio \
	  --disk $VMSTORAGEPATH/$VM_NAME/cloud-init.iso,device=cdrom \
	  --os-type linux \
	  --os-variant ubuntu19.04 \
	  --virt-type kvm \
	  --graphics none \
	  --network bridge=br1 \
	  --import
}


function main {
	checkparams
	build
	exit 0
}

main

