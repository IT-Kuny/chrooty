FROM ubuntu:22.04
ARG BATS_VERSION="1.7.0"
ENV DEBIAN_FRONTEND=noninteractive

RUN apt-get update &&     apt-get install -y --no-install-recommends jq btrfs-progs lvm2 zfsutils-linux dosfstools parted util-linux kpartx 
RUN batstmp="$(mktemp -d bats-core-${BATS_VERSION}.XXXX)" \
    && echo ${batstmp} \
    && cd ${batstmp} \
    && curl -SLO https://github.com/bats-core/bats-core/archive/refs/tags/v${BATS_VERSION}.tar.gz \
    && tar -zxvf v${BATS_VERSION}.tar.gz \
    && bash bats-core-${BATS_VERSION}/install.sh /usr/local \
    && rm -rf "${batstmp}" \
    && rm -rf /var/lib/apt/lists/*

WORKDIR /opt/chrooty
COPY . .

RUN dd if=/dev/zero of=/disk.img bs=1M count=64 && parted /disk.img --script mklabel gpt mkpart primary ext4 1MiB 20MiB mkpart primary fat32 20MiB 40MiB mkpart primary btrfs 40MiB 60MiB && losetup --partscan --find --show /disk.img > /tmp/loopdev && LOOPDEV=$(cat /tmp/loopdev) && mkfs.ext4 "${LOOPDEV}p1" && mkfs.vfat "${LOOPDEV}p2" && mkfs.btrfs "${LOOPDEV}p3"

ENTRYPOINT ["bash","-lc"]
CMD ["docker run --rm --privileged chrooty-test"]
