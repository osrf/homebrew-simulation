class IgnitionTools < Formula
  desc "Entry point for ignition command-line tools"
  homepage "https://ignitionrobotics.org"
  url "https://osrf-distributions.s3.amazonaws.com/ign-tools/releases/ignition-tools-1.0.0~pre2.tar.bz2"
  version "1.0.0~pre2"
  sha256 "98b5b688c9e981b8d4b7dc3775041853b534bae72faabae8c6391cef497e2b6e"
  head "https://bitbucket.org/ignitionrobotics/ign-tools", :branch => "default", :using => :hg

  bottle do
    root_url "https://osrf-distributions.s3.amazonaws.com/bottles-simulation"
    cellar :any_skip_relocation
    sha256 "f2a9cb3e60b18e23444497dedcdf4cdfb1199f54f3b5ce6b9bf2b33d93ddf8ee" => :mojave
    sha256 "3a75a638b843a443bde46b625b11ef82ad0b6a74b9a8ca696bf62ec2b8e8ae24" => :high_sierra
  end

  depends_on "cmake" => :build
  depends_on "ignition-cmake2"

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
