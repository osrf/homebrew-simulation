class IgnitionTools < Formula
  desc "Entry point for ignition command-line tools"
  homepage "https://ignitionrobotics.org"
  url "https://osrf-distributions.s3.amazonaws.com/ign-tools/releases/ignition-tools-1.0.0.tar.bz2"
  sha256 "491e21e08deeb33958743a757828e589741998e014282bf880cd7db7351ccd6e"
  license "Apache-2.0"
  head "https://github.com/ignitionrobotics/ign-tools.git", branch: "ign-tools1"

  bottle do
    root_url "https://osrf-distributions.s3.amazonaws.com/bottles-simulation"
    sha256 cellar: :any_skip_relocation, mojave: "038dcc3dd42f0b235c68b897e169b857a1d79f21bc35017f02b733e8757f62c5"
    sha256 cellar: :any_skip_relocation, high_sierra: "ac37f88b2bc4c37ab143d907531ca2af9917ba680638c5af775d8c26b55164cb"
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
