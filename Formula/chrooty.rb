class Chrooty < Formula
  desc "Rescue and chroot utility with comprehensive volume detection"
  homepage "https://github.com/IT-Kuny/chrooty"
  url "https://github.com/IT-Kuny/chrooty/archive/refs/heads/main.zip"
  version "0.1"
  sha256 "PLACEHOLDER_SHA256"

  depends_on "jq"
  depends_on "btrfs-progs"
  depends_on "lvm2"
  depends_on "zfs"
  depends_on "dosfstools"
  depends_on "parted"
  depends_on "unzip"
  
  def install
    bin.install "chrooty"
    etc.install "hooks/pre_chroot.d"
    etc.install "hooks/post_chroot.d"
  end

  test do
    assert_match "Usage", shell_output("#{bin}/chrooty --help")
  end
end