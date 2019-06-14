class Sdformat4 < Formula
  desc "Simulation Description Format"
  homepage "http://sdformat.org"
  url "https://osrf-distributions.s3.amazonaws.com/sdformat/releases/sdformat-4.4.0.tar.bz2"
  sha256 "4424a984f69d3333f087e7aae1d8fa5aec61ad52e09be39e2f5e2cb69ade1527"
  revision 5

  head "https://bitbucket.org/osrf/sdformat", :branch => "sdf4", :using => :hg

  bottle do
    root_url "https://osrf-distributions.s3.amazonaws.com/bottles-simulation"
    sha256 "f0009e22737945b454aa126d10354e9a28e0722799437e0ef1c7363553169e24" => :mojave
    sha256 "8ca2dca0a7f737943ad4ffa63ce538cabbba49098df9d5b6f76a92ef166801f4" => :high_sierra
    sha256 "202ca00f9e7c5e4a0a4f916e3193466b45f13843bca0b85fca600ffa0cbb3f04" => :sierra
  end

  depends_on "cmake" => :build

  depends_on "boost"
  depends_on "doxygen"
  depends_on "ignition-math2"
  depends_on "pkg-config"
  depends_on "tinyxml"
  depends_on "urdfdom" => :optional

  conflicts_with "sdformat", :because => "Differing version of the same formula"
  conflicts_with "sdformat3", :because => "Differing version of the same formula"
  conflicts_with "sdformat5", :because => "Differing version of the same formula"
  conflicts_with "sdformat6", :because => "Differing version of the same formula"
  conflicts_with "sdformat7", :because => "Differing version of the same formula"
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
        "      <sensor type='imu' name='imu'>"
        "        <imu>"
        "          <noise/>"
        "        </imu>"
        "      </sensor>"
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
    libs = `pkg-config --libs sdformat`.split(" ")
    system ENV.cc, "test.cpp",
                   *cflags,
                   "-L#{lib}",
                   *libs,
                   "-lc++",
                   "-o", "test"
    system "./test"
    # check for Xcode frameworks in bottle
    cmd_not_grep_xcode = "! grep -rnI 'Applications[/]Xcode' #{prefix}"
    system cmd_not_grep_xcode
  end
end
