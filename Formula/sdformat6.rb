class Sdformat6 < Formula
  desc "Simulation Description Format"
  homepage "http://sdformat.org"
  url "https://osrf-distributions.s3.amazonaws.com/sdformat/releases/sdformat-6.3.0.tar.bz2"
  sha256 "108c687d5c3a21b5ab8154f41f99d799d7b2e7632b4cc1914eda8c902581ee7f"
  license "Apache-2.0"
  revision 1

  head "https://github.com/osrf/sdformat.git", branch: "sdf6", using: :git

  bottle do
    root_url "https://osrf-distributions.s3.amazonaws.com/bottles-simulation"
    sha256 catalina: "180a87711cec092ebadf9ef4094d72173939d23103cb6cf5e290010cb2a3d920"
    sha256 mojave:   "02ed3bd2a7f1146e3b42ccd852ada985061a8df07b278bccc583346e52ff84e1"
  end

  depends_on "cmake" => :build

  depends_on "boost"
  depends_on "doxygen"
  depends_on "ignition-math4"
  depends_on "ignition-tools"
  depends_on "pkg-config"
  depends_on "tinyxml"
  depends_on "urdfdom" => :optional

  conflicts_with "sdformat", because: "differing version of the same formula"
  conflicts_with "sdformat3", because: "differing version of the same formula"
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
