class Sdformat4 < Formula
  desc "Simulation Description Format"
  homepage "http://sdformat.org"
  url "http://gazebosim.org/distributions/sdformat/releases/sdformat-4.3.2.tar.bz2"
  sha256 "82147307f0d30fd8bd4dee253cca3e0b6864be5cb2b47249382cd78b466bd9ee"
  revision 1

  head "https://bitbucket.org/osrf/sdformat", :branch => "sdf4", :using => :hg

  bottle do
    root_url "http://gazebosim.org/distributions/sdformat/releases"
    sha256 "608b983e7eaf032c6031651f0094cd83a757b1f33b65f6da7c5deb4645bba3e2" => :sierra
    sha256 "6c83a39a5db3e9707e44bb0b2099264fd450240e4158ef19e0e0c51951ae320d" => :el_capitan
    sha256 "8838a749aef970f1917e606bc09f67d10e03056069ac92973f7d4a2247654931" => :yosemite
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
