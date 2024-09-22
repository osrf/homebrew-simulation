class Simbody < Formula
  desc "Multibody physics API"
  homepage "https://simtk.org/home/simbody"
  url "https://github.com/simbody/simbody/archive/refs/tags/Simbody-3.7.tar.gz"
  sha256 "d371a92d440991400cb8e8e2473277a75307abb916e5aabc14194bea841b804a"
  license "Apache-2.0"

  head "https://github.com/simbody/simbody.git", branch: "master"

  bottle do
    root_url "https://osrf-distributions.s3.amazonaws.com/bottles-simulation"
    sha256 ventura:     "580a4b24af28f9231e699023882be6c73cec56b561c44e918502aab1cfba870c"
    sha256 monterey:    "4550130d4b54cfdd6c6f3bef8c376c0cf4c86f4cb5a1d07332a4200766a39ba5"
    sha256 big_sur:     "e78642e3e328773da2dca9faf741fd7b620501213046017eab1d117b890a373d"
    sha256 catalina:    "4d758a8363a28cbc8d9700a5d66a80b0d55a3470bc6406b7ed36453fa44724a3"
    sha256 mojave:      "2ea952e21afc83d111acacc70af126f0ae5845b270b100451f17400fad0a47df"
    sha256 high_sierra: "5c1fa0c1f7a78a2c9dbdc505ce278a924ea6a4dde555a49051cf862a56ce64f5"
  end

  depends_on "cmake" => :build
  depends_on "doxygen" => :build
  depends_on "pkg-config" => [:build, :test]

  def install
    # Don't use 10.11 SDK frameworks on 10.10 with xcode7
    ENV.delete("MACOSX_DEPLOYMENT_TARGET")
    ENV.delete("SDKROOT")

    # use a build folder
    mkdir "build" do
      system "cmake", "..", *std_cmake_args, "-DCMAKE_INSTALL_RPATH=#{rpath}"
      system "make", "doxygen"
      system "make", "install"
    end

    inreplace Dir[lib/"cmake/simbody/SimbodyTargets-*.cmake"],
        %r{/Applications/+Xcode.app/[^;]*/System/Library},
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
    flags = `pkg-config --cflags --libs simbody`.split
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
