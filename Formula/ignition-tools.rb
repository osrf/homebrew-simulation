class IgnitionTools < Formula
  desc "Entry point for ignition command-line tools"
  homepage "https://ignitionrobotics.org"
  url "https://osrf-distributions.s3.amazonaws.com/ign-tools/releases/ignition-tools-1.0.0~pre3.tar.bz2"
  version "1.0.0~pre3"
  sha256 "27e1692efc8e23b5eb7778782dcb4edb04278f9760d73329f8699606948f4614"
  head "https://bitbucket.org/ignitionrobotics/ign-tools", :branch => "default", :using => :hg

  bottle do
    root_url "https://osrf-distributions.s3.amazonaws.com/bottles-simulation"
    cellar :any_skip_relocation
    sha256 "4b3fa25748cf7752032622ddd327c83f2d2594bee5768322128845b49dd91dc1" => :mojave
    sha256 "d80252f5c46cb12186ccf510f09a1449d1eed30180e0222f42ebb06b62025515" => :high_sierra
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
