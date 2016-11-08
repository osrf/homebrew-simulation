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

  patch do
    # Fix for compatibility with boost 1.58
    url "https://bitbucket.org/ignitionrobotics/ign-common/commits/0b9d89179859291ba082ac0e69c010fb46a153bc/raw"
    sha256 "ebfc7edaf870a6448d5908b78ca601d85b3a8be6fbc540d299a9277e34d09e61"
  end

  def install
    system "cmake", ".", *std_cmake_args
    system "make", "install"
  end

  test do
    (testpath/"test.cpp").write <<-EOS.undent
      #include <iostream>
      #include <ignition/common.hh>
      int main() {
        try {
          ignthrow("An example exception that is caught.");
        }
        catch(const ignition::common::exception &_e) {
          std::cerr << "Caught a runtime error " << _e.what() << std::endl;
        }
        ignassert(0 == 0);
        return 0;
      }
    EOS
    system "pkg-config", "ignition-common"
    # # test doesn't compile yet
    # cflags = `pkg-config --cflags ignition-common`.split(" ")
    # system ENV.cc, "test.cpp",
    #                *cflags,
    #                "-L#{lib}",
    #                "-lignition-common",
    #                "-lc++",
    #                "-o", "test"
    # system "./test"
  end
end
