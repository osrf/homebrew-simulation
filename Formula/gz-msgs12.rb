class GzMsgs12 < Formula
  desc "Middleware protobuf messages for robotics"
  homepage "https://gazebosim.org"
  url "https://github.com/gazebosim/gz-msgs.git", branch: "main"
  version "11.999.999-0-20250528"
  license "Apache-2.0"

  head "https://github.com/gazebosim/gz-msgs.git", branch: "gz-msgs12"

  depends_on "python@3.12" => [:build, :test]
  depends_on "python@3.13" => [:build, :test]
  depends_on "abseil"
  depends_on "cmake"
  depends_on "gz-cmake5"
  depends_on "gz-math9"
  depends_on "gz-tools2"
  depends_on "gz-utils4"
  depends_on macos: :high_sierra # c++17
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

  def install
    rpaths = [
      rpath,
      rpath(source: libexec/"gz/msgs", target: lib),
    ]
    cmake_args = std_cmake_args
    cmake_args << "-DBUILD_TESTING=Off"
    cmake_args << "-DCMAKE_INSTALL_RPATH=#{rpaths.join(";")}"
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
      (lib/"#{python_name}/site-packages/gz/msgs").install_symlink Dir[lib/"python/gz/msgs/*"]
    end
  end

  test do
    system libexec/"gz/msgs/gz-msgs"
    (testpath/"test.cpp").write <<-EOS
      #include <gz/msgs.hh>
      int main() {
        gz::msgs::UInt32;
        return 0;
      }
    EOS
    (testpath/"CMakeLists.txt").write <<-EOS
      cmake_minimum_required(VERSION 3.22.1 FATAL_ERROR)
      find_package(gz-msgs QUIET REQUIRED)
      add_executable(test_cmake test.cpp)
      target_link_libraries(test_cmake gz-msgs::gz-msgs)
    EOS
    # test building with pkg-config
    system "pkg-config", "gz-msgs"
    cflags = `pkg-config --cflags gz-msgs`.split
    system ENV.cc, "test.cpp",
                   *cflags,
                   "-L#{lib}",
                   "-lgz-msgs",
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
      system python.opt_libexec/"bin/python", "-c", "import gz.msgs"
    end
    # check gz msg command
    ENV["GZ_CONFIG_PATH"] = "#{opt_share}/gz"
    system Formula["gz-tools2"].opt_bin/"gz", "msg"
  end
end
