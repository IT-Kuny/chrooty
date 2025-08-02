# chrooty Developer Guide

This guide covers packaging setup, plugin development, and security considerations.

## Repository Layout

```
.
├── chrooty                         # Main script
├── hooks/
│   ├── pre_chroot.d/               # Pre-chroot hooks
│   └── post_chroot.d/              # Post-chroot hooks
├── debian/                         # Debian packaging
├── rpm/                            # RPM packaging
├── Formula/                        # Homebrew formula
├── tests/                          # Bats tests
├── .github/workflows/ci.yml        # CI pipeline
└── DEVELOPER_GUIDE.md              # This guide
```

## Packaging

### Debian

1. Install build tools: `sudo apt-get install -y debhelper devscripts`
2. Update files in `debian/`
3. Build: `dpkg-buildpackage -us -uc`

### RPM

1. Install: `sudo dnf install -y rpm-build`
2. Ensure `rpm/SPECS/chrooty.spec` and `rpm/SOURCES/` are populated.
3. Build: `rpmbuild --define "_topdir $(pwd)/rpm" -ba rpm/SPECS/chrooty.spec`

### Homebrew

1. Set up tap repo: `yourusername/homebrew-chrooty`
2. Place `Formula/chrooty.rb` with correct `url` and `sha256`
3. Tag release: `git tag v0.1 && git push origin v0.1`

## Plugin Architecture

- Hooks reside in `hooks/pre_chroot.d/` and `hooks/post_chroot.d/`.
- Name scripts lexically (`001-init.sh`, etc.).
- Scripts are sourced as root—audit for safety.

## Security Considerations

- Run minimum required code as root.
- Validate all external inputs (labels, fs types).
- Sign packages (`.deb`, `.rpm`) with GPG.
- Review any custom hooks before deployment.
- Audit logs in `/var/log/chrooty.log`.

For more details, see the Developer Overview in the main README.
