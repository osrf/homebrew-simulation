class IgnitionCommon < Formula
  desc "Common libraries for robotics applications"
  homepage "https://bitbucket.org/ignitionrobotics/ign-common"
  # url "http://gazebosim.org/distributions/ign-common/releases/ignition-common-0.4.0.tar.bz2"
  url "https://bitbucket.org/ignitionrobotics/ign-common/get/ebf4b53ee7633d541172953a213ca4009fc122f2.tar.gz"
  version "0.4.0~20170906~ebf4b53"
  sha256 "c28f27c50fad98360b143c1bed270183f7260105b7a21669463400c80efc7ed2"

  head "https://bitbucket.org/ignitionrobotics/ign-common", :branch => "default", :using => :hg

  bottle do
    root_url "http://gazebosim.org/distributions/ign-common/releases"
    sha256 "25483747704aaa04f1d86423e67c195f6f50b57297049d751e7d966a388b6f82" => :sierra
    sha256 "167ab634b6f3afeb0ae72c53c5c6752f3f5d81248b6a1762909b20dc5f00265d" => :el_capitan
    sha256 "ca64d8eca4af6b1a5ff3588c6a58e8c091a9c3d45bf38edd5e336064b79dfc13" => :yosemite
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
