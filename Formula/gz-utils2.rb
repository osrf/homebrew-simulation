class GzUtils2 < Formula
  desc "General purpose classes and functions designed for robotic applications"
  homepage "https://github.com/gazebosim/gz-utils"
  url "https://osrf-distributions.s3.amazonaws.com/gz-utils/releases/gz-utils-2.2.1.tar.bz2"
  sha256 "4c6361ac7a82739837c36385f24e9f643f36e2ef336e3c7b2b5ff7b36d47a052"
  license "Apache-2.0"

  head "https://github.com/gazebosim/gz-utils.git", branch: "gz-utils2"

  bottle do
    root_url "https://osrf-distributions.s3.amazonaws.com/bottles-simulation"
    sha256 cellar: :any, sonoma:   "8b6049fdfffc16a2d793c8601e00fc8543170b027e5a908ee6cdc4819d46c9dc"
    sha256 cellar: :any, ventura:  "434704186995b15e49035f74c68034bdcbfef772d0cf697113dfcfc0392d2716"
    sha256 cellar: :any, monterey: "a2313fadab80f5867eaac4d8a6d0b7e1c8fb96218b78444d7a2c22fe32e6ab65"
  end

  depends_on "cmake" => [:build, :test]
  depends_on "pkgconf" => [:build, :test]
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
    # test building with pkg-config
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
