class IgnitionTools < Formula
  desc "Entry point for ignition command-line tools"
  homepage "https://ignitionrobotics.org"
  url "http://gazebosim.org/distributions/ign-tools/releases/ignition-tools-0.1.0.tar.bz2"
  sha256 "67d41587cf9ab77a0e6586597d5b38e75e17b1ee122ca24414ec5ce9c6b89bc0"
  head "https://bitbucket.org/ignitionrobotics/ign-tools", :branch => "default", :using => :hg

  bottle do
    root_url "http://gazebosim.org/distributions/ign-tools/releases"
    cellar :any
    sha256 "9e4a57da67001ddaaf5da36114ba36be03f605dde427f39bc5ca65f6ac978fba" => :el_capitan
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
