class IgnitionCommon < Formula
  desc "Common libraries for robotics applications"
  homepage "https://bitbucket.org/ignitionrobotics/ign-common"
  url "http://gazebosim.org/distributions/ign-common/releases/ignition-common-0.2.0.tar.bz2"
  sha256 "ab6f9e966863a63378fd906ee4427fb90be2f08538b5ce85996e3f6d753c59d0"

  head "https://bitbucket.org/ignitionrobotics/ign-common", :branch => "default", :using => :hg

  bottle do
    root_url "http://gazebosim.org/distributions/ign-common/releases"
    sha256 "0123456789ABCDEF0123456789ABCDEF0123456789ABCDEF0123456789ABCDEF" => :sierra
    sha256 "a4430b712b0be5f8adcc16c1ae51ffdf652fdb5f81d5e22ee95a0bbf01bbb2e0" => :el_capitan
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
