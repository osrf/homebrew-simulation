class IgnitionRendering0 < Formula
  desc "Rendering library for robotics applications"
  homepage "https://bitbucket.org/ignitionrobotics/ign-rendering"
  url "http://gazebosim.org/distributions/ign-rendering/releases/ignition-rendering0-0.1.0.tar.bz2"
  sha256 "7d0d3e71b0e18f1ac1a8a0313747fc754cc301cfd12c249845b298c049f6ded3"

  head "https://bitbucket.org/ignitionrobotics/ign-rendering", :branch => "default", :using => :hg

  bottle do
    root_url "https://osrf-distributions.s3.amazonaws.com/bottles-simulation"
    sha256 "86f34785e2785fbfaa12f67e6b5486c16068848c82c5119495beb83d096e9d2e" => :mojave
    sha256 "135c3ab87141bc8ffdf8fd1a56a4caff7602049a0454f7e5f99019282d4c9845" => :high_sierra
    sha256 "ce2459a4b043a786c3a559f98436815c59e0b26886aedfbc1a91977406387913" => :sierra
  end

  depends_on "cmake" => :build

  depends_on "freeimage"
  depends_on "ignition-cmake1"
  depends_on "ignition-common2"
  depends_on "ignition-math5"
  depends_on "ogre1.9"
  depends_on "pkg-config"

  patch do
    # Don't conflict with ignition-rendering1
    url "https://bitbucket.org/ignitionrobotics/ign-rendering/commits/8aaa4b8188cae5cd5082e46a05abde6bfcc7fbde/raw/"
    sha256 "87ca51e370faab94d2ff92bc3fde3d236fe5f264a582a5740e047d85818280a8"
  end

  def install
    system "cmake", ".", *std_cmake_args
    system "make", "install"
  end

  test do
    (testpath/"test.cpp").write <<-EOS
      #include <ignition/rendering/PixelFormat.hh>
      int main(int _argc, char** _argv)
      {
        ignition::rendering::PixelFormat pf = ignition::rendering::PF_UNKNOWN;
        return ignition::rendering::PixelUtil::IsValid(pf);
      }
    EOS
    ENV.append_path "PKG_CONFIG_PATH", "#{Formula["qt"].opt_lib}/pkgconfig"
    system "pkg-config", "ignition-rendering0"
    cflags   = `pkg-config --cflags ignition-rendering0`.split(" ")
    ldflags  = `pkg-config --libs ignition-rendering0`.split(" ")
    system ENV.cc, "test.cpp",
                   *cflags,
                   *ldflags,
                   "-lc++",
                   "-o", "test"
    system "./test"
  end
end
