class IgnitionTools < Formula
  desc "Entry point for ignition command-line tools"
  homepage "https://ignitionrobotics.org"
  url "https://osrf-distributions.s3.amazonaws.com/ign-tools/releases/ignition-tools-0.2.0.tar.bz2"
  sha256 "13e74891ff72ed6775e00cf5592444632f88fa22bfd3ba510c347631039aa0f1"
  head "https://bitbucket.org/ignitionrobotics/ign-tools", :branch => "default", :using => :hg

  bottle do
    root_url "https://osrf-distributions.s3.amazonaws.com/bottles-simulation"
    cellar :any_skip_relocation
    sha256 "07f3e030b5ed95a33db038465998ffb03eacf4d6c4d7d65678f6a40e9b26d3e2" => :mojave
    sha256 "092a961c84d20a9a7e2d031b2222a037060543af217b0103e785adecc3eed4d5" => :high_sierra
    sha256 "aa2dfff86d9ee0d04525d697df09cfd87ae02fefcf4b3c85835d6b98bbd3f5cc" => :sierra
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
