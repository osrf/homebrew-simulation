class Sdformat4 < Formula
  desc "Simulation Description Format"
  homepage "http://sdformat.org"
  url "http://gazebosim.org/distributions/sdformat/releases/sdformat-4.3.2.tar.bz2"
  sha256 "82147307f0d30fd8bd4dee253cca3e0b6864be5cb2b47249382cd78b466bd9ee"
  revision 2

  head "https://bitbucket.org/osrf/sdformat", :branch => "sdf4", :using => :hg

  bottle do
    root_url "http://gazebosim.org/distributions/sdformat/releases"
    sha256 "8422a94e44c665505f383ff89b42ebab0411a8fab07da72703b7367b2cf522a1" => :sierra
    sha256 "6e9d06b39e95c2e22165b6738570c36cca8a096f451fe020db8b6c402de3705f" => :el_capitan
    sha256 "04fec31df772e8d128a44272da9ae3eefa6e57ebeee9f62b957169dc3a400b0f" => :yosemite
  end

  depends_on "cmake" => :build

  depends_on "boost"
  depends_on "doxygen"
  depends_on "ignition-math2"
  depends_on "pkg-config" => :run
  depends_on "ros/deps/urdfdom" => :optional
  depends_on "tinyxml"

  conflicts_with "sdformat", :because => "Differing version of the same formula"
  conflicts_with "sdformat3", :because => "Differing version of the same formula"
  conflicts_with "sdformat5", :because => "Differing version of the same formula"

  patch do
    # Fix for cmake 3.9
    url "https://bitbucket.org/osrf/sdformat/commits/3e1d3f3bd0387b548d347b423a2bea39a7872003/raw/"
    sha256 "b7fda735c24bf152c44213368575c1addc9ab91d4125611157f79bef32a36250"
  end

  def install
    ENV.m64

    cmake_args = std_cmake_args
    cmake_args << "-DUSE_EXTERNAL_URDF:BOOL=True" if build.with? "urdfdom"
    cmake_args << ".."

    mkdir "build" do
      system "cmake", *cmake_args
      system "make", "install"
    end
  end

  test do
    (testpath/"test.cpp").write <<-EOS.undent
      #include <iostream>
      #include "sdf/sdf.hh"
      const std::string sdfString(
        "<sdf version='1.5'>"
        "  <model name='example'>"
        "    <link name='link'>"
        "      <sensor type='gps' name='mysensor' />"
        "    </link>"
        "  </model>"
        "</sdf>");
      int main() {
        sdf::SDF modelSDF;
        modelSDF.SetFromString(sdfString);
        std::cout << modelSDF.ToString() << std::endl;
      }
    EOS
    system "pkg-config", "sdformat"
    cflags = `pkg-config --cflags sdformat`.split(" ")
    system ENV.cc, "test.cpp",
                   *cflags,
                   "-L#{lib}",
                   "-lsdformat",
                   "-lc++",
                   "-o", "test"
    system "./test"
  end
end
