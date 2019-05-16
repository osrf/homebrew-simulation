class IgnitionTools < Formula
  desc "Entry point for ignition command-line tools"
  homepage "https://ignitionrobotics.org"
  url "https://osrf-distributions.s3.amazonaws.com/ign-tools/releases/ignition-tools-0.2.0~pre1.tar.bz2"
  version "0.2.0~pre1"
  sha256 "ff18c8ed38e3c15a03344a3c54a67b2b74b3cd9115a3f84c79b12262ea4d51d4"
  head "https://bitbucket.org/ignitionrobotics/ign-tools", :branch => "default", :using => :hg

  bottle do
    root_url "https://osrf-distributions.s3.amazonaws.com/ign-tools/releases"
    cellar :any
    sha256 "9749ed1c0a0fae437ba4f7f2a4605c1defb7c78b3306d7f32b3e322e72d0f511" => :el_capitan
  end

  depends_on "cmake" => :build

  def install
    mkdir "build" do
      system "cmake", "..", *std_cmake_args
      system "make", "install"
    end
  end

  test do
    mkdir testpath/"config"
    (testpath/"config/test.yaml").write <<~EOS
      --- # Test subcommand
      format: 1.0.0
      library_name: test
      library_path: path
      library_version: 2.0.0
      commands:
          - test  : Test utility
      ---
    EOS
    ENV["IGN_CONFIG_PATH"] = testpath/"config/"
    system "#{bin}/ign", "test", "--versions"
  end
end
