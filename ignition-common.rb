class IgnitionCommon < Formula
  desc "Common libraries for robotics applications"
  homepage "https://bitbucket.org/ignitionrobotics/ign-common"
  # url "http://gazebosim.org/distributions/ign-common/releases/ignition-common-0.4.0.tar.bz2"
  url "https://bitbucket.org/ignitionrobotics/ign-common/get/2071c29973ed10a53275c875199be36fb3dc8196.tar.gz"
  version "0.4.0~20170720~2071c29"
  sha256 "cb2bfbd60cfb353c28778f391bb65a13dc31168d9be4478e13f66ba0b9232a88"

  head "https://bitbucket.org/ignitionrobotics/ign-common", :branch => "default", :using => :hg

  bottle do
    root_url "http://gazebosim.org/distributions/ign-common/releases"
    sha256 "d8331ebc0637c02361e93967444abb3253d54e1e90b74b42d6ed84d2b5e94c5c" => :sierra
    sha256 "d452ceab673157a6b6e8bf0a5ed01a45b66453b9e9c93babb7361a108426b0b8" => :el_capitan
    sha256 "4e739efdeeb59ca08f8f62307dda205dfc9800ac899bd4e73ef07696ac4e7c69" => :yosemite
  end

  depends_on "cmake" => :build

  depends_on "ffmpeg"
  depends_on "freeimage"
  depends_on "gts"
  depends_on "ignition-math3"
  depends_on "ossp-uuid"
  depends_on "tinyxml2"

  depends_on "pkg-config" => :run

  def install
    system "cmake", ".", *std_cmake_args
    system "make", "install"
  end

  test do
    (testpath/"test.cpp").write <<-EOS.undent
      #include <iostream>
      #include <ignition/common.hh>
      int main() {
        igndbg << "debug" << std::endl;
        ignwarn << "warn" << std::endl;
        ignerr << "error" << std::endl;
        // // this example code doesn't compile
        // try {
        //   ignthrow("An example exception that is caught.");
        // }
        // catch(const ignition::common::exception &_e) {
        //   std::cerr << "Caught a runtime error " << _e.what() << std::endl;
        // }
        // ignassert(0 == 0);
        return 0;
      }
    EOS
    system "pkg-config", "ignition-common0"
    cflags = `pkg-config --cflags ignition-common0`.split(" ")
    system ENV.cc, "test.cpp",
                   *cflags,
                   "-L#{lib}",
                   "-lignition-common0",
                   "-lc++",
                   "-o", "test"
    system "./test"
  end
end
