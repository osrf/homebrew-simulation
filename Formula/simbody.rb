class Simbody < Formula
  desc "Multibody physics API"
  homepage "https://simtk.org/home/simbody"
  url "https://github.com/simbody/simbody/archive/Simbody-3.7.tar.gz"
  sha256 "d371a92d440991400cb8e8e2473277a75307abb916e5aabc14194bea841b804a"

  head "https://github.com/simbody/simbody.git", :branch => "master"

  bottle do
    root_url "https://osrf-distributions.s3.amazonaws.com/bottles-simulation"
    sha256 "f782a48a58e646ca6fdf97cc39d9c7c2eed5d039b8a9cfcebcf685891f210c6d" => :mojave
    sha256 "7ea5d3458a0c254d631d3be880473890939cc9ff87cc0b6cfe294b97b1d4df40" => :high_sierra
    sha256 "65042cc670f294351cce80d7381d9998d77a6b8d9a8b55eb018d98ec41d95462" => :sierra
  end

  depends_on "cmake" => :build
  depends_on "doxygen" => :build
  depends_on "pkg-config"

  def install
    # Don't use 10.11 SDK frameworks on 10.10 with xcode7
    ENV.delete("MACOSX_DEPLOYMENT_TARGET")
    ENV.delete("SDKROOT")
    ENV.m64

    mkdir "build" do
      system "cmake", "..", *std_cmake_args
      system "make", "doxygen"
      system "make", "install"
    end

    inreplace Dir[lib/"cmake/simbody/SimbodyTargets-*.cmake"],
        %r{/Applications[/]Xcode.app/[^;]*/System/Library},
        "/System/Library", false
  end

  test do
    (testpath/"test.cpp").write <<-EOS
      #include "simbody/Simbody.h"
      using namespace SimTK;
      int main() {
        // Create the system.
        MultibodySystem system;
        SimbodyMatterSubsystem matter(system);
        GeneralForceSubsystem forces(system);
        Force::UniformGravity gravity(forces, matter, Vec3(0, -9.8, 0));
        Body::Rigid pendulumBody(MassProperties(1.0, Vec3(0), Inertia(1)));
        pendulumBody.addDecoration(Transform(), DecorativeSphere(0.1));
        MobilizedBody::Pin pendulum1(matter.Ground(), Transform(Vec3(0)),
                                     pendulumBody, Transform(Vec3(0, 1, 0)));
        MobilizedBody::Pin pendulum2(pendulum1, Transform(Vec3(0)),
                                     pendulumBody, Transform(Vec3(0, 1, 0)));
        // Initialize the system and state.
        system.realizeTopology();
        State state = system.getDefaultState();
        pendulum2.setRate(state, 5.0);
        // Simulate it.
        RungeKuttaMersonIntegrator integ(system);
        TimeStepper ts(system, integ);
        ts.initialize(state);
        ts.stepTo(50.0);
      }
    EOS
    system "pkg-config", "simbody"
    flags = `pkg-config --cflags --libs simbody`.split(" ")
    system ENV.cxx, "test.cpp", *flags, "-o", "test"
    system "./test"
    # check for Xcode frameworks in bottle
    # ! requires system with single argument, which uses standard shell
    # put in variable to avoid audit complaint
    # enclose / in [] so the following line won't match itself
    cmd_not_grep_xcode = "! grep -rnI 'Applications[/]Xcode' #{prefix}"
    system cmd_not_grep_xcode
  end
end
