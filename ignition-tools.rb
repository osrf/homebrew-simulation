class IgnitionTools < Formula
  desc "Entry point for ignition command-line tools"
  homepage "http://ignitionrobotics.org"
  url "https://bitbucket.org/ignitionrobotics/ign-tools/get/381c0a968fa.tar.gz"
  version "0.0.0-20160209-381c0a968fa"
  sha256 "8ea662be885d84342c2522c41b6d24cd42adf8e1e9e4e21fdfd2c4fbbc62a170"

  depends_on "cmake" => :build

  def install
    mkdir "build" do
      system "cmake", "..", *std_cmake_args
      system "make", "install"
    end
  end

  test do
    system "false"
  end
end
