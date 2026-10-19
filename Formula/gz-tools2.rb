class GzTools2 < Formula
  desc "Entry point for Gazebo command-line tools"
  homepage "https://gazebosim.org"
  url "https://osrf-distributions.s3.amazonaws.com/gz-tools/releases/gz-tools-2.0.4.tar.bz2"
  sha256 "e4ee9cbe45528249268dc9c97c24199cf5479fd4c0f304e946051035867f121d"
  license "Apache-2.0"

  head "https://github.com/gazebosim/gz-tools.git", branch: "gz-tools2"

  bottle do
    root_url "https://osrf-distributions.s3.amazonaws.com/bottles-simulation"
    sha256 cellar: :any, arm64_tahoe:   "e165191d59e11d5d26f6d81f292e93361e6e2841b02842c1c0cd2fee5c114c00"
    sha256 cellar: :any, arm64_sequoia: "b73456efafd516af34fbf08f69ed9452c3ed246db0e222e4c0a36d2cac6184dd"
    sha256 cellar: :any, arm64_sonoma:  "b98faa8afaad9352a41036fbaaee58a0e30982f59a55bd282387afeddd904ad0"
    sha256 cellar: :any, sonoma:        "b80cfb723415c4075aa0baf31039751e539f5fd7540988ef6e5e0cea0f219935"
  end

  depends_on "cmake" => :build
  depends_on "libyaml" => :test
  depends_on "ruby" => :test
  depends_on "gz-cmake3"

  conflicts_with "gazebo11", because: "both install bin/gz"
  conflicts_with "gz-rotary-tools", because: "both install bin/gz"

  def install
    inreplace "src/gz.in" do |s|
      s.gsub! "@CMAKE_INSTALL_PREFIX@", HOMEBREW_PREFIX
    end

    cmake_args = std_cmake_args

    # Disable doc target due to bug in doxygen 1.18
    # see https://github.com/osrf/homebrew-simulation/issues/3616
    cmake_args << "-DBUILD_DOCS=OFF"

    mkdir "build" do
      system "cmake", "-S", "..", "-B", ".", *cmake_args
      system "make", "install"
    end
  end

  test do
    mkdir testpath/"config"
    (testpath/"config/test.yaml").write <<~EOS
      --- # Test subcommand
      format: 1.0.0
      library_name: test
      library_path: path
      library_version: 2.0.0
      commands:
          - test  : Test utility
      ---
    EOS
    ENV["GZ_CONFIG_PATH"] = testpath/"config/"
    system "#{bin}/gz", "test", "--versions"
  end
end
