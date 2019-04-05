class Sdformat7 < Formula
  desc "Simulation Description Format"
  homepage "http://sdformat.org"
  url "https://bitbucket.org/osrf/sdformat/get/f6b1f8e573d2af8abc40f63f3deb363de2472280.tar.gz"
  version "6.999.999~20190808~f6b1f8e"
  sha256 "cc58b11d5f7af8db0f293bef7cffdf86609ea233806ccfe065caeb38776ec954"

  head "https://bitbucket.org/osrf/sdformat", :branch => "sdf7", :using => :hg

  bottle do
    root_url "https://osrf-distributions.s3.amazonaws.com/bottles-simulation"
    sha256 "ba0798dc96e5c7044c4a9c1e3de7558fa141c3442d185307fb58292ca374b908" => :mojave
    sha256 "4b2b10f850c00393d2772964fd895856ad7f8edcbd57747f69c95927be31fb78" => :high_sierra
    sha256 "c6bc10aeeda21616645773d176188157f408561033e46f6ad4d20cd23c80da92" => :sierra
  end

  depends_on "cmake" => :build

  depends_on "boost"
  depends_on "doxygen"
  depends_on "ignition-math5"
  depends_on "ignition-tools"
  depends_on "pkg-config"
  depends_on "tinyxml"
  depends_on "urdfdom" => :optional

  conflicts_with "sdformat", :because => "Differing version of the same formula"
  conflicts_with "sdformat3", :because => "Differing version of the same formula"
  conflicts_with "sdformat4", :because => "Differing version of the same formula"
  conflicts_with "sdformat5", :because => "Differing version of the same formula"
  conflicts_with "sdformat6", :because => "Differing version of the same formula"
  conflicts_with "sdformat8", :because => "Differing version of the same formula"

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
