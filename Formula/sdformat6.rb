class Sdformat6 < Formula
  desc "Simulation Description Format"
  homepage "http://sdformat.org"
  url "https://osrf-distributions.s3.amazonaws.com/sdformat/releases/sdformat-6.3.1.tar.bz2"
  sha256 "24f8c314b14fd3e999eead5a9b788f98395cc861bf8b562d8bccca758eddecc1"
  license "Apache-2.0"

  head "https://github.com/osrf/sdformat.git", branch: "sdf6", using: :git

  bottle do
    root_url "https://osrf-distributions.s3.amazonaws.com/bottles-simulation"
    sha256 catalina: "0f22b36ec9c727706020029cee63a1027258f9838b08f1181d69013d681d3233"
    sha256 mojave:   "806ec541bc295efbab6fb7331388e17d566ba73ff44b1203d057e8df084fc78b"
  end

  depends_on "cmake" => :build

  depends_on "boost"
  depends_on "doxygen"
  depends_on "ignition-math4"
  depends_on "ignition-tools"
  depends_on "pkg-config"
  depends_on "tinyxml"
  depends_on "urdfdom" => :optional

  conflicts_with "sdformat4", because: "differing version of the same formula"
  conflicts_with "sdformat5", because: "differing version of the same formula"
  conflicts_with "sdformat7", because: "differing version of the same formula"

  def install
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
    cflags = `pkg-config --cflags sdformat`.split
    system ENV.cc, "test.cpp",
                   *cflags,
                   "-L#{lib}",
                   "-lsdformat",
                   "-lc++",
                   "-o", "test"
    system "./test"
    # check for Xcode frameworks in bottle
    cmd_not_grep_xcode = "! grep -rnI 'Applications[/]Xcode' #{prefix}"
    system cmd_not_grep_xcode
  end
end
