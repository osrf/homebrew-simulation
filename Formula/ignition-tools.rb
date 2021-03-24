class IgnitionTools < Formula
  desc "Entry point for ignition command-line tools"
  homepage "https://ignitionrobotics.org"
  url "https://osrf-distributions.s3.amazonaws.com/ign-tools/releases/ignition-tools-1.1.0~pre1.tar.bz2"
  version "1.1.0~pre1"
  sha256 "fd10f8ab35a5d6e88f1e5c5b64422cf306a52a012d0b8547f83e20c7d4bd0aa9"
  license "Apache-2.0"
  head "https://github.com/ignitionrobotics/ign-tools.git", branch: "ign-tools1"

  bottle do
    root_url "https://osrf-distributions.s3.amazonaws.com/bottles-simulation"
    sha256 cellar: :any_skip_relocation, catalina: "97345cf27a2118f8e713ec838f5ed148a3c20acf505fc3e31618b0208dd1531b"
    sha256 cellar: :any_skip_relocation, mojave:   "f7ca39784a280b4eff12b73f966eb7940e2f723cc89189b6f74449cd977f97ad"
  end

  depends_on "cmake" => :build
  depends_on "libyaml" => :test
  depends_on "ruby" => :test

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
