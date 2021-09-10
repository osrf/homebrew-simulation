class IgnitionTools < Formula
  desc "Entry point for ignition command-line tools"
  homepage "https://ignitionrobotics.org"
  url "https://osrf-distributions.s3.amazonaws.com/ign-tools/releases/ignition-tools-1.3.0~pre1.tar.bz2"
  version "1.3.0~pre1"
  sha256 "5ca99f0b83dd8452b592f582e0607e6cb6e56d5dcc350ee762b2a7286efe7256"
  license "Apache-2.0"
  head "https://github.com/ignitionrobotics/ign-tools.git", branch: "ign-tools1"

  bottle do
    root_url "https://osrf-distributions.s3.amazonaws.com/bottles-simulation"
    sha256 cellar: :any_skip_relocation, catalina: "e54d75d9bbfdc4df3f76d9c4c8913282a315bd5c8d4c4c3725fb587177581d98"
    sha256 cellar: :any_skip_relocation, mojave:   "93929c0c7472dc7122320f5a0b68fef7adcea7ab1af01fc566065bb5c9c7ff21"
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
