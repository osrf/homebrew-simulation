class GzUtils2 < Formula
  desc "General purpose classes and functions designed for robotic applications"
  homepage "https://github.com/gazebosim/gz-utils"
  url "https://osrf-distributions.s3.amazonaws.com/gz-utils/releases/gz-utils-2.1.0.tar.bz2"
  sha256 "42342b83dcd80bcf4f71240da48f9c0b71e4adbf1c6a22e458f3286a453b70a7"
  license "Apache-2.0"

  head "https://github.com/gazebosim/gz-utils.git", branch: "gz-utils2"

  bottle do
    root_url "https://osrf-distributions.s3.amazonaws.com/bottles-simulation"
    sha256 cellar: :any, ventura:  "aad3d9657218e1d5980659ac55adbcc9a1e3e82b7df79c44b2ca7f97f0cc1f6b"
    sha256 cellar: :any, monterey: "5e3b750887a113b4775d05e6b15a14d3d915f9f0f4029c92109460d837ea0b49"
    sha256 cellar: :any, big_sur:  "06232e41bb86374561a8b325429be785770fa108644286329f4453f429612d1d"
    sha256 cellar: :any, catalina: "b59cfd89d536d1d5c6635f460a61f65649970718798ec2269c3c848be5456443"
  end

  depends_on "cmake" => [:build, :test]
  depends_on "pkg-config" => [:build, :test]
  depends_on "gz-cmake3"

  def install
    cmake_args = std_cmake_args
    cmake_args << "-DBUILD_TESTING=OFF"
    cmake_args << "-DCMAKE_INSTALL_RPATH=#{rpath}"

    # Use build folder
    mkdir "build" do
      system "cmake", "..", *cmake_args
      system "make", "install"
    end
  end

  test do
    (testpath/"test.cpp").write <<-EOS
      #include <gz/utils/ImplPtr.hh>
      class SomeClassPrivate
      {
      };
      class SomeClass
      {
        private: gz::utils::ImplPtr<SomeClassPrivate> dataPtr =
            gz::utils::MakeImpl<SomeClassPrivate>();
      };
      int main() {
        SomeClass object;
        return 0;
      }
    EOS
    (testpath/"CMakeLists.txt").write <<-EOS
      cmake_minimum_required(VERSION 3.5 FATAL_ERROR)
      find_package(gz-utils2 QUIET REQUIRED)
      add_executable(test_cmake test.cpp)
      target_link_libraries(test_cmake gz-utils2::gz-utils2)
    EOS
    system "pkg-config", "gz-utils2"
    cflags = `pkg-config --cflags gz-utils2`.split
    ldflags = `pkg-config --libs gz-utils2`.split
    system ENV.cxx, "test.cpp",
                    *cflags,
                    *ldflags,
                    "-o", "test"
    system "./test"
    # test building with cmake
    mkdir "build" do
      system "cmake", ".."
      system "make"
      system "./test_cmake"
    end
    # check for Xcode frameworks in bottle
    cmd_not_grep_xcode = "! grep -rnI 'Applications[/]Xcode' #{prefix}"
    system cmd_not_grep_xcode
  end
end
