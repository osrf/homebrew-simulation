class Sdformat6 < Formula
  desc "Simulation Description Format"
  homepage "http://sdformat.org"
  url "http://gazebosim.org/distributions/sdformat/releases/sdformat-6.0.0.tar.bz2"
  sha256 "93ea8007e9d92c87f99240e378231977fb1de2072fd752449f65917cb430bc4d"

  head "https://bitbucket.org/osrf/sdformat", :branch => "default", :using => :hg

  bottle do
    root_url "http://gazebosim.org/distributions/sdformat/releases"
    sha256 "7209872eecf22ff4628a68da52c91368798b5bc9078ef7017a4da2fe920a4f45" => :high_sierra
    sha256 "4cbd66c4d028115f55ded390ba472720c29139863dcbff3b735d40c21ac5b9a1" => :sierra
    sha256 "207a41808a55897963e4f05a39ba6d7b6c639fd1fab4eb1c13a51bae16d36c29" => :el_capitan
  end

  depends_on "cmake" => :build

  depends_on "boost"
  depends_on "doxygen"
  depends_on "ignition-math4"
  depends_on "pkg-config" => :run
  depends_on "ros/deps/urdfdom" => :optional
  depends_on "tinyxml"

  conflicts_with "sdformat", :because => "Differing version of the same formula"
  conflicts_with "sdformat3", :because => "Differing version of the same formula"
  conflicts_with "sdformat4", :because => "Differing version of the same formula"
  conflicts_with "sdformat5", :because => "Differing version of the same formula"

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
