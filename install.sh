#! /bin/sh

if [ ! -e /etc/zfs-yubikey.cfg ]; then
	cp zfs-yubikey.cfg /etc/zfs-yubikey.cfg
	chmod 640 /etc/zfs-yubikey.cfg
fi

. /etc/zfs-yubikey.cfg

apt update
apt install -y yubikey-personalization

cp hooks/zfs-yubikey-unlock /usr/share/initramfs-tools/hooks/zfs-yubikey-unlock
chmod 755 /usr/share/initramfs-tools/hooks/zfs-yubikey-unlock

mkdir /usr/share/initramfs-tools/scripts/init-premount
chmod 755 /usr/share/initramfs-tools/scripts/init-premount

cp init-premount/zfs-yubikey-encrypt-root /usr/share/initramfs-tools/scripts/init-premount/zfs-yubikey-encrypt-root
chmod 755 /usr/share/initramfs-tools/scripts/init-premount/zfs-yubikey-encrypt-root

cp local-premount/zfs-yubikey-unlock /usr/share/initramfs-tools/scripts/local-premount/zfs-yubikey-unlock
chmod 755 /usr/share/initramfs-tools/scripts/local-premount/zfs-yubikey-unlock

cp zfs-yubikey-unlock /usr/share/initramfs-tools/zfs-yubikey-unlock
chmod 755 /usr/share/initramfs-tools/zfs-yubikey-unlock

cp zfs-yubikey-encrypt-root /usr/share/initramfs-tools/zfs-yubikey-encrypt-root
chmod 755 /usr/share/initramfs-tools/zfs-yubikey-encrypt-root

if [ ! -z "$CHALLENGE_FILE" ]; then
	if [ ! -e "$CHALLENGE_FILE" ]; then
		head -c 64 /dev/urandom > "$CHALLENGE_FILE"
	fi
fi


if [ -z "$CHALLENGE" -a -z "$CHALLENGE_FILE" ]; then
	echo "WARNING: no challenge is specified in /etc/zfs-yubikey.cfg"
	exit 1
fi

update-initramfs -u
