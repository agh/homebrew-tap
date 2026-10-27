class Cwtch < Formula
  desc "Manage Claude Code profiles and sync configuration from Git"
  homepage "https://github.com/agh/cwtch"
  url "https://github.com/agh/cwtch/archive/refs/tags/v6.1.0.tar.gz"
  sha256 "630774598df926b25f6dcc5aa1f66f2ff0372c6f8d1f509308db5beff1dde1bb"
  license "MIT"

  livecheck do
    url :stable
    strategy :github_latest
  end

  depends_on "jq"
  depends_on :macos
  depends_on "yq"

  def install
    libexec.install "bin"
    libexec.install "lib"
    libexec.install "VERSION"
    bin.install_symlink libexec/"bin/cwtch"
  end

  def caveats
    <<~EOS
      `cwtch profile setup` needs Claude Code, installed separately.

      This project is not affiliated with Anthropic PBC.
    EOS
  end

  test do
    assert_match "cwtch #{version}", shell_output("#{bin}/cwtch --version")

    system bin/"cwtch", "sync", "init"
    assert_match "Cwtchfile is valid", shell_output("#{bin}/cwtch sync check")

    pipe_output("#{bin}/cwtch profile save-key test", "homebrew-test-not-a-real-api-key\n", 0)
    profile = testpath/".cwtch/profiles/test"
    assert_equal "test", shell_output("#{bin}/cwtch profile current").strip
    assert_equal 0600, (profile/".apikey").stat.mode & 0777

    system bin/"cwtch", "profile", "delete", "test"
    refute_path_exists profile
    assert_equal "(none)", shell_output("#{bin}/cwtch profile current").strip

    (testpath/".cwtch/Cwtchfile").atomic_write("sources: not-a-list\n")
    assert_match "'sources' must be a list", shell_output("#{bin}/cwtch sync check 2>&1", 1)
  end
end
