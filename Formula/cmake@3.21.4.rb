class CmakeAT3214 < Formula
  desc "Cross-platform make"
  homepage "https://www.cmake.org/"
  url "https://github.com/Kitware/CMake/releases/download/v3.21.4/cmake-3.21.4.tar.gz"
  mirror "http://fresh-center.net/linux/misc/cmake-3.21.4.tar.gz"
  mirror "http://fresh-center.net/linux/misc/legacy/cmake-3.21.4.tar.gz"
  sha256 "d9570a95c215f4c9886dd0f0564ca4ef8d18c30750f157238ea12669c2985978"
  license "BSD-3-Clause"
  head "https://gitlab.kitware.com/cmake/cmake.git", branch: "master"

  # The "latest" release on GitHub has been an unstable version before, so we
  # check the Git tags instead.
  livecheck do
    url :stable
    regex(/^v?(\d+(?:\.\d+)+)$/i)
  end

  bottle do
    root_url "https://osrf-distributions.s3.amazonaws.com/bottles-simulation"
    sha256 cellar: :any_skip_relocation, big_sur:  "e4da0b3c1ae8a96ce62d25f6ccb854bed2c2bcf9b02f1b89c884e4bf8f976cc7"
    sha256 cellar: :any_skip_relocation, catalina: "abad60e38212e1fd6502c3a4dc90ccb21f2f91fef510888f7c78d427b0441f7f"
  end

  keg_only :versioned_formula

  disable! date: "2024-08-31", because: "is past end-of-life date"
  deprecate! date: "2023-01-25", because: "is past end-of-life date"

  uses_from_macos "ncurses"

  on_linux do
    depends_on "openssl@1.1"
  end

  # The completions were removed because of problems with system bash

  # The `with-qt` GUI option was removed due to circular dependencies if
  # CMake is built with Qt support and Qt is built with MySQL support as MySQL uses CMake.
  # For the GUI application please instead use `brew install --cask cmake`.

  def install
    args = %W[
      --prefix=#{prefix}
      --no-system-libs
      --parallel=#{ENV.make_jobs}
      --datadir=/share/cmake
      --docdir=/share/doc/cmake
      --mandir=/share/man
    ]
    if OS.mac?
      args += %w[
        --system-zlib
        --system-bzip2
        --system-curl
      ]
    end

    system "./bootstrap", *args, "--", *std_cmake_args,
                                       "-DCMake_INSTALL_EMACS_DIR=#{elisp}",
                                       "-DCMake_BUILD_LTO=ON"
    system "make"
    system "make", "install"

    # Remove deprecated and unusable binary
    # https://gitlab.kitware.com/cmake/cmake/-/issues/20235
    (share/"cmake/Modules/Internal/CPack/CPack.OSXScriptLauncher.in").unlink
  end

  def caveats
    <<~EOS
      To install the CMake documentation, run:
        brew install cmake-docs
    EOS
  end

  test do
    (testpath/"CMakeLists.txt").write("find_package(Ruby)")
    system bin/"cmake", "."

    # These should be supplied in a separate cmake-docs formula.
    refute_path_exists doc/"html"
    refute_path_exists man
  end
end
