class BulletAT287 < Formula
  desc "Physics SDK"
  homepage "https://bulletphysics.org/"
  url "https://github.com/bulletphysics/bullet3/archive/2.87.tar.gz"
  sha256 "438c151c48840fe3f902ec260d9496f8beb26dba4b17769a4a53212903935f95"
  license "Zlib"
  head "https://github.com/bulletphysics/bullet3.git"

  option "with-framework", "Build frameworks"
  option "with-demo", "Build demo applications"
  option "with-double-precision", "Use double precision"

  deprecated_option "framework" => "with-framework"
  deprecated_option "build-demo" => "with-demo"
  deprecated_option "double-precision" => "with-double-precision"

  depends_on "cmake" => :build

  def install
    args = std_cmake_args + %W[
      -DINSTALL_EXTRA_LIBS=ON -DBUILD_UNIT_TESTS=OFF -DBUILD_PYBULLET=OFF
      -DCMAKE_INSTALL_RPATH=#{lib}
    ]
    args << "-DUSE_DOUBLE_PRECISION=ON" if build.with? "double-precision"

    args_shared = args.dup + %w[
      -DBUILD_BULLET2_DEMOS=OFF -DBUILD_SHARED_LIBS=ON
    ]

    args_framework = %W[
      -DFRAMEWORK=ON
      -DCMAKE_INSTALL_PREFIX=#{frameworks}
      -DCMAKE_INSTALL_NAME_DIR=#{frameworks}
    ]

    args_shared += args_framework if build.with? "framework"

    args_static = args.dup << "-DBUILD_SHARED_LIBS=OFF"
    args_static <<
      if build.without? "demo"
        "-DBUILD_BULLET2_DEMOS=OFF"
      else
        "-DBUILD_BULLET2_DEMOS=ON"
      end

    mkdir "build" do
      system "cmake", "..", *args_shared
      system "make", "install"

      system "make", "clean"

      system "cmake", "..", *args_static
      system "make", "install"

      if build.with? "demo"
        rm_rf Dir["examples/**/Makefile", "examples/**/*.cmake", "examples/**/CMakeFiles"]
        pkgshare.install "examples"
        (pkgshare/"examples").install "../data"
      end
    end
  end

  test do
    (testpath/"test.cpp").write <<~EOS
      #include "LinearMath/btPolarDecomposition.h"
      int main() {
        btMatrix3x3 I = btMatrix3x3::getIdentity();
        btMatrix3x3 u, h;
        polarDecompose(I, u, h);
        return 0;
      }
    EOS

    cxx_lib = if OS.mac?
      "-lc++"
    else
      "-lstdc++"
    end

    if build.with? "framework"
      system ENV.cc, "test.cpp", "-F#{frameworks}", "-framework", "LinearMath",
                     "-I#{frameworks}/LinearMath.framework/Headers", cxx_lib,
                     "-o", "f_test"
      system "./f_test"
    end

    system ENV.cc, "test.cpp", "-I#{include}/bullet", "-L#{lib}",
                   "-lLinearMath", cxx_lib, "-o", "test"
    system "./test"
  end
end
