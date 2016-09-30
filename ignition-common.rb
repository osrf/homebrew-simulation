class IgnitionCommon < Formula
  desc "Common libraries for robotics applications"
  homepage "https://bitbucket.org/ignitionrobotics/ign-common"
  url "http://gazebosim.org/distributions/ign-common/releases/ignition-common-0.1.0.tar.bz2"
  sha256 "466dccacc5fbace145fde3c13d0f39a21f701b5595a745a7e25f5fd136bf65e7"

  head "https://bitbucket.org/ignitionrobotics/ign-common", :branch => "default", :using => :hg

  depends_on "cmake" => :build

  depends_on "ffmpeg"
  depends_on "freeimage"
  depends_on "gts"
  depends_on "ignition-math2"
  depends_on "ossp-uuid"
  depends_on "tinyxml2"

  depends_on "pkg-config" => :run

  def install
    system "cmake", ".", *std_cmake_args
    system "make", "install"
  end

  test do
    system "pkg-config", "--modversion", "ignition-common"
  end
end
