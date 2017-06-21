class IgnitionCommon < Formula
  desc "Common libraries for robotics applications"
  homepage "https://bitbucket.org/ignitionrobotics/ign-common"
  url "http://gazebosim.org/distributions/ign-common/releases/ignition-common-0.4.0.tar.bz2"
  sha256 "48eac350749a4bbc48de4fd1dbab3b0a35f9a3d9f9b0ba9b51958f8be63dee97"
  revision 1

  head "https://bitbucket.org/ignitionrobotics/ign-common", :branch => "default", :using => :hg

  bottle do
    root_url "http://gazebosim.org/distributions/ign-common/releases"
    sha256 "c805801fd74e4cacc04cf4de444a232ee0536aa5fdb0365a3fee0198aeaf2bc7" => :sierra
    sha256 "aa6311aeb5fcc5699803957c978caa58cfae749d58e7016d15c6ec6ba67a8017" => :el_capitan
    sha256 "04dc5b93784a444edfd1900792807105413c10a65d3a23dd940e0d6a1c79c1c5" => :yosemite
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
