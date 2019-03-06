class IgnitionRendering0 < Formula
  desc "Rendering library for robotics applications"
  homepage "https://bitbucket.org/ignitionrobotics/ign-rendering"
  url "http://gazebosim.org/distributions/ign-rendering/releases/ignition-rendering0-0.1.0.tar.bz2"
  sha256 "7d0d3e71b0e18f1ac1a8a0313747fc754cc301cfd12c249845b298c049f6ded3"

  head "https://bitbucket.org/ignitionrobotics/ign-rendering", :branch => "default", :using => :hg

  bottle do
    root_url "https://osrf-distributions.s3.amazonaws.com/bottles-simulation"
    sha256 "ad402c4978497b188cd95019d41da6ef90075f18d5e08434a8b441b339d7c7af" => :mojave
    sha256 "001e9175fcdd530d02e38a1218abab777d08008b184d75fff70bcbb5b4edecac" => :high_sierra
    sha256 "4325e4ccccc6ecd828228673073aefad5f787ec7a3e43c730e7d9fdf70bb429e" => :sierra
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
