Name:           chrooty
Version:        0.1
Release:        1%{?dist}
Summary:        Rescue and chroot utility with comprehensive volume detection

License:        MIT
URL:            https://github.com/IT-Kuny/chrooty
Source0:        %{name}-%{version}.tar.gz

BuildRequires:  jq, btrfs-progs, lvm2, zfsutils-linux, dosfstools, parted, util-linux
Requires:       bash, coreutils, jq, btrfs-progs, lvm2, zfsutils-linux, dosfstools, parted, util-linux

%description
chrooty automates chroot-based rescue operations—including LVM, ZFS, Btrfs
subvolume handling, EFI mounts, and extensive logging—and supports both
interactive and automated workflows.

%prep
%autosetup -n %{name}-%{version}

%install
install -d %{buildroot}%{_bindir}
install -m0755 chrooty %{buildroot}%{_bindir}/chrooty

%files
%{_bindir}/chrooty
%doc README.md CONTRIBUTING.md CODE_OF_CONDUCT.md

%changelog
* Fri Aug 02 2025 0n1cOn3 <it@it-kuny> - 0.1-1
- Initial RPM release
