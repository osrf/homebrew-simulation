class GzTools2 < Formula
  desc "Entry point for Gazebo command-line tools"
  homepage "https://gazebosim.org"
  url "https://osrf-distributions.s3.amazonaws.com/gz-tools/releases/gz-tools-2.0.0~pre1.tar.bz2"
  version "2.0.0~pre1"
  sha256 "a44ca627f6ce0f74a19b79c0fbc9dc61e366af315d12f8342aedb0f817d85db0"
  license "Apache-2.0"

  bottle do
    root_url "https://osrf-distributions.s3.amazonaws.com/bottles-simulation"
    sha256 cellar: :any, big_sur:  "29e95a97c94fdb1a9b597f87b290029cb06124732aaa876d7e270d74e3fdeb3d"
    sha256 cellar: :any, catalina: "e27470a65492b765f853723faa398c88b706e27d258b0fd9cbaf21bb86a9cb35"
  end

  depends_on "cmake" => :build
  depends_on "libyaml" => :test
  depends_on "ruby" => :test
  depends_on "gz-cmake3"

  conflicts_with "gazebo9", because: "both install bin/gz"
  conflicts_with "gazebo11", because: "both install bin/gz"

  patch :DATA

  def install
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

__END__
diff --git a/src/gz.in b/src/gz.in
index 14e456f..947c424 100755
--- a/src/gz.in
+++ b/src/gz.in
@@ -50 +50 @@ yaml_found = false
-conf_dirs = '@CMAKE_INSTALL_PREFIX@/share/gz/'
+conf_dirs = 'HOMEBREW_PREFIX/share/gz/'
