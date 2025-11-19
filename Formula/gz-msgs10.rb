class GzMsgs10 < Formula
  desc "Middleware protobuf messages for robotics"
  homepage "https://gazebosim.org"
  url "https://osrf-distributions.s3.amazonaws.com/gz-msgs/releases/gz-msgs-10.3.2.tar.bz2"
  sha256 "0dd9c19dee7aec7fc0f7bdd03ee2ae44ab1068dac2fc1ae8cc3ecc1b6df8472a"
  license "Apache-2.0"
  revision 18

  bottle do
    root_url "https://osrf-distributions.s3.amazonaws.com/bottles-simulation"
    sha256 arm64_sequoia: "5fb9cd87704112eda4fb91b59a44a885504190d1b478a5a6ca74110a0d7046ae"
    sha256 arm64_sonoma:  "670bcc5eb5b04c43ec5a7c3c745df23603bc479976cce8acc88df68c12b17a84"
    sha256 sonoma:        "817e48cb2181071696936e9eea022dfa56a6356eca67d81a4b901a31e8565784"
  end

  # head "https://github.com/gazebosim/gz-msgs.git", branch: "gz-msgs10"

  depends_on "python@3.12" => [:build, :test]
  depends_on "python@3.13" => [:build, :test]
  depends_on "python@3.14" => [:build, :test]
  depends_on "abseil"
  depends_on "cmake"
  depends_on "gz-cmake3"
  depends_on "gz-math7"
  depends_on "gz-tools2"
  depends_on "gz-utils2"
  depends_on "pkgconf"
  depends_on "protobuf"
  depends_on "tinyxml2"

  def pythons
    deps.map(&:to_formula)
        .select { |f| f.name.match?(/^python@3\.\d+$/) }
  end

  def python_cmake_arg(python = Formula["python@3.13"])
    "-DPython3_EXECUTABLE=#{python.opt_libexec}/bin/python"
  end

  patch do
    # Fix for compatibility with protobuf 30
    url "https://github.com/gazebosim/gz-msgs/commit/ebdd05f6d51c990876085bcc9db9f79df59d375a.patch?full_index=1"
    sha256 "050137fb0900b7d7cab36b612cc3bc319c3f093aba9c958d13c66ce44a6199b2"
  end

  def install
    cmake_args = std_cmake_args
    cmake_args << "-DBUILD_TESTING=Off"
    cmake_args << "-DCMAKE_INSTALL_RPATH=#{rpath}"
    cmake_args << python_cmake_arg

    mkdir "build" do
      system "cmake", "..", *cmake_args
      system "make", "install"
    end

    # this installs python files for each message that can be used by multiple
    # versions of python, so symlink the files to versioned python folders
    pythons.each do |python|
      # remove @ from formula name
      python_name = python.name.tr("@", "")
      # symlink the python files directly instead of the parent folder to avoid
      # brew link errors if there is a pre-existing __pycache__ folder
      (lib/"#{python_name}/site-packages/gz/msgs10").install_symlink Dir[lib/"python/gz/msgs10/*"]
    end
  end

  test do
    (testpath/"test.cpp").write <<-EOS
      #include <gz/msgs.hh>
      int main() {
        gz::msgs::UInt32;
        return 0;
      }
    EOS
    (testpath/"CMakeLists.txt").write <<-EOS
      cmake_minimum_required(VERSION 3.10 FATAL_ERROR)
      find_package(gz-msgs10 QUIET REQUIRED)
      add_executable(test_cmake test.cpp)
      target_link_libraries(test_cmake gz-msgs10::gz-msgs10)
    EOS
    # test building with pkg-config
    system "pkg-config", "gz-msgs10"
    cflags = `pkg-config --cflags gz-msgs10`.split
    system ENV.cc, "test.cpp",
                   *cflags,
                   "-L#{lib}",
                   "-lgz-msgs10",
                   "-lc++",
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
    # check python import
    pythons.each do |python|
      system python.opt_libexec/"bin/python", "-c", "import gz.msgs10"
    end
    system Formula["python3"].opt_libexec/"bin/python", "-c", "import gz.msgs10"
  end
end
