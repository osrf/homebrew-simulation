class Sdformat7 < Formula
  desc "Simulation Description Format"
  homepage "http://sdformat.org"
  url "https://github.com/osrf/sdformat/archive/fc497c4408e9e111f66588140cadfcbc17827894.tar.gz"
  version "6.999.999~20190809~f6b1f8e"
  sha256 "f6b67acabb22194ef33df5ef95646ad717f59d737e9e8d473b0d9b674d4c199f"
  license "Apache-2.0"

  head "https://github.com/osrf/sdformat.git", branch: "sdf7", using: :git

  bottle do
    root_url "https://osrf-distributions.s3.amazonaws.com/bottles-simulation"
    sha256 mojave:      "88c59fe865c964a20675dbcbb1837ff2294dfaa5eba8f14eeb8be319eecd4e81"
    sha256 high_sierra: "b8f2b76bad1c9e70b6485b6303ddb0b03883465895174dd45e6aa7b8352e2560"
    sha256 sierra:      "7196965b2e2771a43d71217372194836e41cbf9768bbbc4eed32de09a91f9135"
  end

  depends_on "cmake" => :build

  depends_on "boost"
  depends_on "doxygen"
  depends_on "ignition-math5"
  depends_on "ignition-tools"
  depends_on "pkg-config"
  depends_on "tinyxml"
  depends_on "urdfdom" => :optional

  conflicts_with "sdformat", because: "differing version of the same formula"
  conflicts_with "sdformat3", because: "differing version of the same formula"
  conflicts_with "sdformat4", because: "differing version of the same formula"
  conflicts_with "sdformat5", because: "differing version of the same formula"
  conflicts_with "sdformat6", because: "differing version of the same formula"

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
