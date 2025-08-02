FROM ubuntu:22.04

ENV DEBIAN_FRONTEND=noninteractive

RUN apt-get update &&     apt-get install -y --no-install-recommends       jq       btrfs-progs       lvm2       zfsutils-linux       dosfstools       parted       util-linux       losetup       kpartx       bats-core &&     rm -rf /var/lib/apt/lists/*

WORKDIR /opt/chrooty
COPY . .

RUN dd if=/dev/zero of=/disk.img bs=1M count=64 &&     parted /disk.img --script mklabel gpt       mkpart primary ext4 1MiB 20MiB       mkpart primary fat32 20MiB 40MiB       mkpart primary btrfs 40MiB 60MiB &&     losetup --partscan --find --show /disk.img > /tmp/loopdev &&     LOOPDEV=$(cat /tmp/loopdev) &&     mkfs.ext4 "${LOOPDEV}p1" &&     mkfs.vfat "${LOOPDEV}p2" &&     mkfs.btrfs "${LOOPDEV}p3"

ENTRYPOINT ["bash","-lc"]
CMD ["docker run --rm --privileged chrooty-test"]
