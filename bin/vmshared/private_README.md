# VM shared directory

## When copying a template server

In server config:
- Change NAME of server
- change the forwarded port

on host machine:

run
  
  ```
  utmctl sp NAME PORT
  ```

on guest

  ```
  sudo hostname NAME
  ```

## Commands

Commands prefixed with '01' are the 'main' commands. 
Files prefixed with '02' are 'helpers'.

Main files:

- 01-k3d-setup.sh
	- Install k3d and kubectl (with the needed dependencies like 'docker.io' etc.)

## The directory

This directory is shared in

  UTM  /var/host-share

  ```
  sudo mkdir /mnt/macos /var/host-share
  ```

  Added to /etc/fstab:

  ```
  share   /mnt/macos      9p      trans=virtio,version=9p2000.L,rw,_netdev,nofail 0       0
  /mnt/macos   /var/host-share fuse.bindfs map=501/1000:@20/@1000,x-systemd.requires=/mnt/macos 0 0
  ```
