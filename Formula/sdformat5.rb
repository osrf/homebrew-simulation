class Sdformat5 < Formula
  desc "Simulation Description Format"
  homepage "http://sdformat.org"
  url "https://osrf-distributions.s3.amazonaws.com/sdformat/releases/sdformat-5.3.0.tar.bz2"
  sha256 "e5946e84431cf7874cf422d5b5a9f34f42b31d82b5baea532d1e466011bd89e0"
  license "Apache-2.0"
  revision 5

  head "https://github.com/osrf/sdformat.git", branch: "sdf5", using: :git

  bottle do
    root_url "https://osrf-distributions.s3.amazonaws.com/bottles-simulation"
    sha256 mojave:      "2f8ad2df0a00ef492d8336f30c839139972e94ab5b4ddb72a14dc7d78bede658"
    sha256 high_sierra: "4873b0683399a7e7237642c4fd37fb2229d87c146f955f1c6e067571f391f63a"
    sha256 sierra:      "491df711abe40a502245af24bc20a1d4c3e0a181fa6c45469b3e5534f4e4cd9b"
  end

  depends_on "cmake" => :build

  depends_on "boost"
  depends_on "doxygen"
  depends_on "ignition-math3"
  depends_on "pkg-config"
  depends_on "tinyxml"
  depends_on "urdfdom" => :optional

  conflicts_with "sdformat", because: "differing version of the same formula"
  conflicts_with "sdformat3", because: "differing version of the same formula"
  conflicts_with "sdformat4", because: "differing version of the same formula"
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
  end
end
