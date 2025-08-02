# Contributing to chrooty

Thank you for your interest in contributing to **chrooty**! We welcome all contributions—bug reports, feature requests, documentation improvements, and code patches.

## Getting Started

1. **Fork** the repository and **clone** your fork:
   ```bash
   git clone https://github.com/<your-username>/chrooty.git
   cd chrooty
   ```
2. **Create a branch** for your work:
   ```bash
   git checkout -b feature/my-feature
   ```
3. **Install dependencies**:
   ```bash
   sudo apt-get update
   sudo apt-get install -y jq btrfs-progs lvm2 zfsutils-linux dosfstools parted util-linux losetup kpartx bats-core shellcheck shfmt
   ```

## Development Workflow

- **Code Style**: Run `shfmt -l -w .` and `shellcheck -x ./*.sh` before committing.
- **Testing**:
  - Unit & integration: `bats tests/*.sh`
  - Containerized: `docker build -t chrooty-test . && docker run --rm --privileged chrooty-test`
- **Hooks**: Place executable scripts in `hooks/pre_chroot.d/` or `hooks/post_chroot.d/` with lexical ordering (e.g., `001-setup.sh`).

## Commit Messages

- Use **imperative** tone: `feat: add exfat support`
- Include scope if helpful: `fix(mount): handle busy unmount`
- Reference issues: `fix: cleanup trap issue (#42)`

## Pull Requests

1. Rebase your branch:  
   ```bash
   git fetch upstream
   git rebase upstream/main
   ```
2. Push and open a PR against `main`.
3. Describe what you changed, why, and any trade-offs.

We'll review within 3 business days. Thank you!
