class Sdformat7 < Formula
  desc "Simulation Description Format"
  homepage "http://sdformat.org"
  url "https://bitbucket.org/osrf/sdformat/get/f6b1f8e573d2af8abc40f63f3deb363de2472280.tar.gz"
  version "6.999.999~20190808~f6b1f8e"
  sha256 "cc58b11d5f7af8db0f293bef7cffdf86609ea233806ccfe065caeb38776ec954"

  head "https://bitbucket.org/osrf/sdformat", :branch => "sdf7", :using => :hg

  bottle do
    root_url "https://osrf-distributions.s3.amazonaws.com/bottles-simulation"
    sha256 "88c59fe865c964a20675dbcbb1837ff2294dfaa5eba8f14eeb8be319eecd4e81" => :mojave
    sha256 "b8f2b76bad1c9e70b6485b6303ddb0b03883465895174dd45e6aa7b8352e2560" => :high_sierra
    sha256 "7196965b2e2771a43d71217372194836e41cbf9768bbbc4eed32de09a91f9135" => :sierra
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
