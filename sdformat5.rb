class Sdformat5 < Formula
  desc "Simulation Description Format"
  homepage "http://sdformat.org"
  url "http://gazebosim.org/distributions/sdformat/releases/sdformat-5.3.0.tar.bz2"
  sha256 "e5946e84431cf7874cf422d5b5a9f34f42b31d82b5baea532d1e466011bd89e0"

  head "https://bitbucket.org/osrf/sdformat", :branch => "default", :using => :hg

  bottle do
    root_url "http://gazebosim.org/distributions/sdformat/releases"
    cellar :any
    sha256 "2de6ac352cb730f898f70cae2d58009e27a1fc9af18853b91eebd2e1ad504c4d" => :high_sierra
    sha256 "670437cc6f17f3578a6e6f5de9be68fb32b8cc8ac77826777e8c59b5b7e591f0" => :sierra
    sha256 "f3bfaab432d3ee7e61490211ab20ba2c96d5bb0395867751d0e5bd1861238a69" => :el_capitan
    sha256 "2e99b2addc656a73a60632f47720449b7d01610cfdeeab66e61a200125439e8b" => :yosemite
  end

  depends_on "cmake" => :build

  depends_on "boost"
  depends_on "doxygen"
  depends_on "ignition-math3"
  depends_on "pkg-config" => :run
  depends_on "ros/deps/urdfdom" => :optional
  depends_on "tinyxml"

  conflicts_with "sdformat", :because => "Differing version of the same formula"
  conflicts_with "sdformat3", :because => "Differing version of the same formula"
  conflicts_with "sdformat4", :because => "Differing version of the same formula"

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
