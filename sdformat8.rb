class Sdformat8 < Formula
  desc "Simulation Description Format"
  homepage "http://sdformat.org"
  url "https://bitbucket.org/osrf/sdformat/get/6a7c07aa6114147983d3d0343e553748135dda7f.tar.gz"
  version "7.999.999~20180614~6a7c07a"
  sha256 "29d488903de1f69db55ab634022a876f09cf781a1c952ef4a2a2897d7476cb50"

  bottle do
    root_url "http://gazebosim.org/distributions/sdformat/releases"
    sha256 "0135409a727a741f8e7431eac51d7fdf3db7186f4a5b4c33ba850c5c3044a40a" => :mojave
    sha256 "9a10b503bafc0f68bd73c8dbb3e2588995a5678b5306b4b413429a2dcccfe791" => :high_sierra
  end

  depends_on "cmake" => :build

  depends_on "boost"
  depends_on "doxygen"
  depends_on "ignition-math6"
  depends_on "pkg-config"
  depends_on "tinyxml"
  depends_on "urdfdom" => :optional

  conflicts_with "sdformat", :because => "Differing version of the same formula"
  conflicts_with "sdformat3", :because => "Differing version of the same formula"
  conflicts_with "sdformat4", :because => "Differing version of the same formula"
  conflicts_with "sdformat5", :because => "Differing version of the same formula"
  conflicts_with "sdformat6", :because => "Differing version of the same formula"
  conflicts_with "sdformat7", :because => "Differing version of the same formula"

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
    (testpath/"test.cpp").write <<-EOS
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
