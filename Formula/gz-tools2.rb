class GzTools2 < Formula
  desc "Entry point for Gazebo command-line tools"
  homepage "https://gazebosim.org"
  url "https://osrf-distributions.s3.amazonaws.com/gz-tools/releases/gz-tools-2.0.3.tar.bz2"
  sha256 "86ea83e1628ad904b456297531f1469f4c3a4df569a6c40e8f8c77f0e3e46156"
  license "Apache-2.0"

  # head "https://github.com/gazebosim/gz-tools.git", branch: "gz-tools2"

  bottle do
    root_url "https://osrf-distributions.s3.amazonaws.com/bottles-simulation"
    sha256 cellar: :any, arm64_sequoia: "140517b9db6b06a0f2f5d1a881df3f0b2a611db5a4585c54cabd3ac719b8b7bc"
    sha256 cellar: :any, arm64_sonoma:  "2c8a576087df170bb575a92b9a679430c5c583b1672a9f1d34e4a57a4f2c8102"
    sha256 cellar: :any, sonoma:        "d18bf41adcee1a222f1fa88b176de06837af97f41afdb8fb8deb7d1ee2e1ec72"
    sha256 cellar: :any, ventura:       "abe1874c7f6612299211f14d8a46b8b08135d3fc8553afe54ccb7895cfc837c9"
  end

  depends_on "cmake" => :build
  depends_on "libyaml" => :test
  depends_on "ruby" => :test
  depends_on "gz-cmake3"

  conflicts_with "gazebo11", because: "both install bin/gz"
  conflicts_with "gz-tools3", because: "both install bin/gz"

  def install
    inreplace "src/gz.in" do |s|
      s.gsub! "@CMAKE_INSTALL_PREFIX@", HOMEBREW_PREFIX
    end

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
