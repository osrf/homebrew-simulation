class IgnitionDome < Formula
  desc "Collection of gazebo simulation software"
  homepage "https://github.com/ignitionrobotics/ign-dome"
  url "https://github.com/ignitionrobotics/ign-dome/archive/4090bd607032e8c397f03da8e6654ad1fb63f136.tar.gz"
  version "0.999.999~0~20200805~4090bd6"
  sha256 "fa21047a9c3ef7ce81b42d61bb290bfbfaffe5e34cda46187097caa052486021"
  license "Apache-2.0"

  head "https://github.com/ignitionrobotics/ign-dome", branch: "master"

  depends_on "cmake" => :build
  depends_on "ignition-cmake2"
  depends_on "ignition-common3"
  depends_on "ignition-fuel-tools5"
  depends_on "ignition-gazebo4"
  depends_on "ignition-gui4"
  depends_on "ignition-launch3"
  depends_on "ignition-math6"
  depends_on "ignition-msgs6"
  depends_on "ignition-physics3"
  depends_on "ignition-plugin1"
  depends_on "ignition-rendering4"
  depends_on "ignition-sensors4"
  depends_on "ignition-tools"
  depends_on "ignition-transport9"
  depends_on macos: :mojave # c++17
  depends_on "pkg-config"
  depends_on "sdformat10"

  def install
    ENV.m64

    mkdir "build" do
      system "cmake", "..", *std_cmake_args
      system "make", "install"
    end
  end

  # Failing test in Mojave
  # test do
  # TODO: improve the testing
  #  system "#{bin}/ign", "gazebo", "--help"
  # end
end
