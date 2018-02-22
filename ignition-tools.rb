class IgnitionTools < Formula
  desc "Entry point for ignition command-line tools"
  homepage "https://ignitionrobotics.org"
  url "http://gazebosim.org/distributions/ign-tools/releases/ignition-tools-0.1.0.tar.bz2"
  sha256 "67d41587cf9ab77a0e6586597d5b38e75e17b1ee122ca24414ec5ce9c6b89bc0"
  head "https://bitbucket.org/ignitionrobotics/ign-tools", :branch => "default", :using => :hg

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
