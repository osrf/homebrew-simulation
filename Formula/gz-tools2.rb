class GzTools2 < Formula
  desc "Entry point for Gazebo command-line tools"
  homepage "https://gazebosim.org"
  url "https://osrf-distributions.s3.amazonaws.com/gz-tools/releases/gz-tools-2.0.1.tar.bz2"
  sha256 "0a99277ebad5494736be0fd9c39c27a62e8a9e97663c63a0be5957a94253e659"
  license "Apache-2.0"

  head "https://github.com/gazebosim/gz-tools.git", branch: "gz-tools2"

  bottle do
    root_url "https://osrf-distributions.s3.amazonaws.com/bottles-simulation"
    sha256 cellar: :any, ventura:  "df8ab04b123477100769de5c472020335bb7df5aa5054dd6d09c157f9531a1b5"
    sha256 cellar: :any, monterey: "4be43e915e0f6fb8c02eabbc174ffd54270860d0c1fc72cb0c8a6fc20ecc3531"
    sha256 cellar: :any, big_sur:  "9519599bc5aa05866fe561eda915bcc83543f64be48a90c7ba6d304ce8a2cc42"
    sha256 cellar: :any, catalina: "effc20690e226877faf1f2674528a73d22604be503dc25b85c9705355a2ab1d5"
  end

  depends_on "cmake" => :build
  depends_on "libyaml" => :test
  depends_on "ruby" => :test
  depends_on "gz-cmake3"

  conflicts_with "gazebo9", because: "both install bin/gz"
  conflicts_with "gazebo11", because: "both install bin/gz"

  def install
    inreplace "src/gz.in" do |s|
      s.gsub! "@CMAKE_INSTALL_PREFIX@", HOMEBREW_PREFIX
    end

    # Use build folder
    mkdir "build" do
      system "cmake", "..", *std_cmake_args
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
