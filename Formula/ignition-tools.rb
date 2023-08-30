class IgnitionTools < Formula
  desc "Entry point for ignition command-line tools"
  homepage "https://ignitionrobotics.org"
  url "https://osrf-distributions.s3.amazonaws.com/ign-tools/releases/ignition-tools-1.5.0.tar.bz2"
  sha256 "00cf5d2eb6222784d6db4de6baffc068013b1fd71d733f496c9f99addc12117d"
  license "Apache-2.0"
  revision 1

  head "https://github.com/gazebosim/gz-tools.git", branch: "ign-tools1"

  bottle do
    root_url "https://osrf-distributions.s3.amazonaws.com/bottles-simulation"
    sha256 cellar: :any, ventura:  "5aa02b63f35605148b4d2d698bc6fb259a801e71b2d3d30ca5570f9ce9712def"
    sha256 cellar: :any, monterey: "b71312917e1bf3be636dd7b328529cee00246681a13088a26a1da94f3cc9bd79"
    sha256 cellar: :any, big_sur:  "9402482d4365a56f82a98e2ba77bd8dfbccbf13a046b7e8fed764914120509d4"
    sha256 cellar: :any, catalina: "41f0d2252bf63b397066d8b82b1e48186deac5aabc57cc9a7dbb4b332fa7131f"
  end

  depends_on "cmake" => :build
  depends_on "libyaml" => :test
  depends_on "ruby" => :test

  def install
    inreplace "src/ign.in" do |s|
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
    ENV["IGN_CONFIG_PATH"] = testpath/"config/"
    system "#{bin}/ign", "test", "--versions"
  end
end
