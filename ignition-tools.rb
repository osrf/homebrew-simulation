class IgnitionTools < Formula
  desc "Entry point for ignition command-line tools"
  homepage "http://ignitionrobotics.org"
  url "https://bitbucket.org/ignitionrobotics/ign-tools/get/381c0a968fa.tar.gz"
  version "0.0.0-20160209-381c0a968fa"
  sha256 "8ea662be885d84342c2522c41b6d24cd42adf8e1e9e4e21fdfd2c4fbbc62a170"
  head "https://bitbucket.org/ignitionrobotics/ign-tools", :branch => "default", :using => :hg

  bottle do
    root_url "http://gazebosim.org/distributions/ign-tools/releases"
    cellar :any
    sha256 "9e4a57da67001ddaaf5da36114ba36be03f605dde427f39bc5ca65f6ac978fba" => :el_capitan
    sha256 "9e4a57da67001ddaaf5da36114ba36be03f605dde427f39bc5ca65f6ac978fba" => :yosemite
  end

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
