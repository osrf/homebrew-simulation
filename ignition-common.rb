class IgnitionCommon < Formula
  desc "Common libraries for robotics applications"
  homepage "https://bitbucket.org/ignitionrobotics/ign-common"
  url "http://gazebosim.org/distributions/ign-common/releases/ignition-common-0.3.0.tar.bz2"
  sha256 "24fd5c9ed49e3d0e54f0057537383ef07aa7eebd2d622ca5e1ad1e5b39929cb8"

  head "https://bitbucket.org/ignitionrobotics/ign-common", :branch => "default", :using => :hg

  bottle do
    root_url "http://gazebosim.org/distributions/ign-common/releases"
    sha256 "227da45580c1e134fc4b08d69c1f2431324b07769bf14538a2fa1a8e235920ab" => :sierra
    sha256 "60e86c7cd4687599b5b973990a28577b77ba63afc357d8e6a47ce4c71ed0743a" => :el_capitan
    sha256 "faea53b4dcee4f11b4173d7cd74478a178ddbe19ef504e965142aa57c5513300" => :yosemite
  end

  depends_on "cmake" => :build

  depends_on "ffmpeg"
  depends_on "freeimage"
  depends_on "gts"
  depends_on "ignition-math3"
  depends_on "ossp-uuid"
  depends_on "tinyxml2"

  depends_on "pkg-config" => :run

  # require ignition-math3 in pkgconfig file
  patch :DATA

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

__END__
diff -r b3d0e504a4a7 cmake/pkgconfig/ignition-common.in
--- a/cmake/pkgconfig/ignition-common.in	Mon Apr 10 19:31:33 2017 +0200
+++ b/cmake/pkgconfig/ignition-common.in	Wed Apr 12 00:16:04 2017 -0700
@@ -5,6 +5,6 @@
 Name: Ignition @IGN_PROJECT_NAME@
 Description: A set of @IGN_PROJECT_NAME@ classes for robot applications
 Version: @PROJECT_VERSION_FULL@
-Requires:
+Requires: ignition-math3
 Libs: -L${libdir} -l@PROJECT_NAME_LOWER@
 CFlags: -I${includedir}
