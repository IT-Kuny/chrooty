#!/usr/bin/env bats
load 'test_helper/bats-support/load'
load 'test_helper/bats-assert/load'

# Stub environment for chrooty
setup() {
  export PATH="$BATS_TEST_DIRNAME/mocks:$PATH"
  mkdir -p mocks
}

teardown() {
  rm -rf mocks
}

# Helper to stub a command with STUB_OUTPUT
stub_cmd() {
  local cmd="$1"
  cat <<'EOF' > "mocks/$cmd"
#!/usr/bin/env bash
eval "echo \"$STUB_OUTPUT\""
EOF
  chmod +x "mocks/$cmd"
}

@test "detect_partitions selects ext4 partition" {
  local dev="disk1"
  export STUB_OUTPUT='{"blockdevices":[{"name":"'"$dev"'","type":"part","fstype":"ext4"}]}'
  stub_cmd lsblk
  run bash -c "source ../chrooty; detect_partitions"
  assert_success
  assert_output --partial "ROOT_PART=/dev/${dev}"
}

@test "detect_partitions selects btrfs and subvol" {
  local dev="disk2"
  export STUB_OUTPUT='{"blockdevices":[{"name":"'"$dev"'","type":"part","fstype":"btrfs"}]}'
  stub_cmd lsblk
  # btrfs subvolume list stub
  cat <<'EOF' > mocks/btrfs
#!/usr/bin/env bash
if [[ "$*" == *"subvolume list"* ]]; then
  echo "   ID 256 path @"
else
  exit 0
fi
EOF
  chmod +x mocks/btrfs
  # mount/umount stubs
  stub_cmd mount; stub_cmd umount
  run bash -c "source ../chrooty; detect_partitions"
  assert_success
  assert_output --partial "BTRFS_SUBVOL=@"
  assert_output --partial "ROOT_PART=/dev/${dev}"
}

@test "detect_partitions selects LVM LV" {
  local dev="disk3"
  export STUB_OUTPUT='{"blockdevices":[{"name":"'"$dev"'","type":"part","fstype":"LVM2_member"}]}'
  stub_cmd lsblk
  # lvscan stub
  cat <<'EOF' > mocks/lvscan
#!/usr/bin/env bash
echo '  ACTIVE    "/dev/vg/root"'
EOF
  chmod +x mocks/lvscan
  run bash -c "source ../chrooty; detect_partitions"
  assert_success
  assert_output --partial "ROOT_PART=/dev/vg/root"
}

@test "detect_partitions selects ZFS zvol" {
  local dev="disk4"
  export STUB_OUTPUT='{"blockdevices":[{"name":"'"$dev"'","type":"part","fstype":"zfs_member"}]}'
  stub_cmd lsblk
  # zfs list stub
  cat <<'EOF' > mocks/zfs
#!/usr/bin/env bash
echo "pool/vol"
EOF
  chmod +x mocks/zfs
  run bash -c "source ../chrooty; detect_partitions"
  assert_success
  assert_output --partial "ROOT_PART=/dev/zvol/pool/vol"
}

@test "detect_partitions detects EFI partition" {
  local dev="uefi1"
  export STUB_OUTPUT='{"blockdevices":[{"name":"'"$dev"'","type":"part","partlabel":"EFI System","fstype":"vfat"},{"name":"d2","type":"part","fstype":"ext4"}]}'
  stub_cmd lsblk
  run bash -c "source ../chrooty; detect_partitions"
  assert_success
  assert_output --partial "EFI_PART=/dev/${dev}"
}
