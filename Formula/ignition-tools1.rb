class IgnitionTools1 < Formula
  desc "Entry point for ignition command-line tools"
  homepage "https://ignitionrobotics.org"
  url "https://bitbucket.org/ignitionrobotics/ign-tools/get/277dda7b2c36ef87387fc571c4e717f41c14eb2b.tar.bz2"
  version "0.999.999~pre0~20190911~277dda7"
  sha256 "b45a82d27ae121e63aa0245d0649ccdc59b7c93d893bbbb05fccafaa394b1979"
  head "https://bitbucket.org/ignitionrobotics/ign-tools", :branch => "default", :using => :hg

  bottle do
    root_url "https://osrf-distributions.s3.amazonaws.com/bottles-simulation"
    cellar :any_skip_relocation
    sha256 "6eb3ef450a4be90a7b0213075d0526dcd05527432ed3414f327a5e45968575ff" => :mojave
    sha256 "83dd5a2a58dbbc03315505405c6822464d32cc716663c4aba5fae850b7b24157" => :high_sierra
  end

  depends_on "cmake" => :build
  depends_on "ignition-cmake2"

  conflicts_with "ignition-tools", :because => "Differing version of the same formula"

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
    ENV["IGN_CONFIG_PATH"] = testpath/"config/"
    system "#{bin}/ign", "test", "--versions"
  end
end
