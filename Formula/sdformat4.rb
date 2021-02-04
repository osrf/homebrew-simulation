class Sdformat4 < Formula
  desc "Simulation Description Format"
  homepage "http://sdformat.org"
  url "https://osrf-distributions.s3.amazonaws.com/sdformat/releases/sdformat-4.4.0.tar.bz2"
  sha256 "4424a984f69d3333f087e7aae1d8fa5aec61ad52e09be39e2f5e2cb69ade1527"
  license "Apache-2.0"
  revision 5

  head "https://github.com/osrf/sdformat.git", branch: "sdf4", using: :git

  bottle do
    root_url "https://osrf-distributions.s3.amazonaws.com/bottles-simulation"
    sha256 mojave:      "f4926ac28179ed217c034f7b69a42176b7a8290be7dd91bb87fcd5fe96f64daf"
    sha256 high_sierra: "b727234177c477d3de90413ac7880ecca91e0c73acf69fcf6c2a2d3b099806b1"
    sha256 sierra:      "d0b28be274c293fd1c5395fcae0be37f43f6c16ef129a171d39a020564e6b7f9"
  end

  depends_on "cmake" => :build

  depends_on "boost"
  depends_on "doxygen"
  depends_on "ignition-math2"
  depends_on "pkg-config"
  depends_on "tinyxml"
  depends_on "urdfdom" => :optional

  conflicts_with "sdformat", because: "differing version of the same formula"
  conflicts_with "sdformat3", because: "differing version of the same formula"
  conflicts_with "sdformat5", because: "differing version of the same formula"
  conflicts_with "sdformat6", because: "differing version of the same formula"
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
    cflags = `pkg-config --cflags sdformat`.split
    libs = `pkg-config --libs sdformat`.split
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
