class Sdformat4 < Formula
  desc "Simulation Description Format"
  homepage "http://sdformat.org"
  url "http://gazebosim.org/distributions/sdformat/releases/sdformat-4.2.0.tar.bz2"
  sha256 "75e2d053f97ca33456109b4d7794e6b7d26deef59c778f0d9e25d1369b24b094"
  revision 2

  head "https://bitbucket.org/osrf/sdformat", :branch => "default", :using => :hg

  bottle do
    #root_url "http://gazebosim.org/distributions/ign-math/releases"
    root_url "http://px4-travis.s3.amazonaws.com/toolchain/bottles"
    sha256 "41980363d24f72d749322f4a8b3fca3e20223d5fd62df9004ff3eb2a438b8e7c" => :el_capitan
    sha256 "e2d043add111f1729f1c188506a65ebbe390099b0e46d7eb6be1592384d0f045" => :yosemite
    sha256 "d93b4d90b5ac2166f25a4c1e47904734b5acd1dd4001d72227c88a2bbbf9a300" => :sierra
  end

  depends_on "cmake" => :build

  # There is a link error with latest boost
  # dyld: Symbol not found: __ZNK5boost16re_detail_10630031cpp_regex_traits_implementationIcE17transform_primaryEPKcS4_
  depends_on "boost"
  depends_on "doxygen"
  depends_on "ignition-math2"
  depends_on "pkg-config" => :run
  depends_on "ros/deps/urdfdom" => :optional
  depends_on "tinyxml"

  conflicts_with "sdformat", :because => "Differing version of the same formula"
  conflicts_with "sdformat3", :because => "Differing version of the same formula"

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
