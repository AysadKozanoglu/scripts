#!/bin/bash

# author: Aysad Koaznoglu

# cloud-init KVM automation 


# need tool for cloud-init creation 
apt install cloud-utils whois -y


VMSTORAGEPATH=/mnt/lvmvg01storageraid1  # this is my path to my VM containers as storate path - change it


# debug
echo $1" "$2
#exit 1

CLOUD_INIT_IMG=$1
       VM_NAME=$2
      USERNAME=suser  # change it
      PASSWORD=suser  # change it
           RAM=1024   # change it if to low 
         VMSIZE=10G   # change it if to low

function checkparams {
	if [[ ! $CLOUD_INIT_IMG ]]; then
		echo " give a cloud bas image file name see /var/lib/libvirt/images/templates/"
		tree /var/lib/libvirt/images/templates/
		exit 1
	fi
	
	
	if [[ ! $VM_NAME ]]; then
		echo "give new vm name"
		exit 1
	fi
}


function build {

	mkdir $VMSTORAGEPATH/$VM_NAME
	qemu-img convert /var/lib/libvirt/images/templates/$CLOUD_INIT_IMG $VMSTORAGEPATH/$VM_NAME/root-disk.qcow2
	qemu-img resize $VMSTORAGEPATH/$VM_NAME/root-disk.qcow2 $VMSIZE
	
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
" | sudo tee $VMSTORAGEPATH/$VM_NAME/cloud-init.cfg

	cloud-localds $VMSTORAGEPATH/$VM_NAME/cloud-init.iso $VMSTORAGEPATH/$VM_NAME/cloud-init.cfg
	
	virt-install \
	  --name $VM_NAME \
	  --memory $RAM \
	  --disk $VMSTORAGEPATH/$VM_NAME/root-disk.qcow2,device=disk,bus=virtio \
	  --disk $VMSTORAGEPATH/$VM_NAME/cloud-init.iso,device=cdrom \
	  --os-type linux \
	  --os-variant ubuntu19.04 \
	  --virt-type kvm \
	  --graphics none \
	  --network network=default \
	  --import
}

cloud-localds $VMSTORAGEPATH//$VM_NAME/cloud-init.iso $VMSTORAGEPATH/$VM_NAME/cloud-init.cfg

function main {
	checkparams
	build
	exit 0
}

main
