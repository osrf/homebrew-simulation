class Simbody < Formula
  desc "Multibody physics API"
  homepage "https://simtk.org/home/simbody"
  url "https://github.com/simbody/simbody/archive/Simbody-3.6.1.tar.gz"
  sha256 "7716d6ea20b950e71e8535faa4353ac89716c03fd7a445dd802eb6a630796639"

  head "https://github.com/simbody/simbody.git", :branch => "master"

  bottle do
    root_url "http://gazebosim.org/distributions/bottles-simulation"
    sha256 "61618279759115f0312f7ea896462c1e39ce2f7ad1a26bb8b0c1f3fd37a858f4" => :mojave
    sha256 "56f3b7eb258a2e8496339bcbfe0859511c132b70feabc63760eef855ae16a7cb" => :high_sierra
    sha256 "e4908b1ab765cdfad161a9f7e9e6031dcead593909fe7e88115ac9c19d7662e0" => :sierra
  end

  depends_on "cmake" => :build
  depends_on "doxygen" => :build
  depends_on "pkg-config"

  patch do
    # Fix pkg-config file
    url "https://github.com/scpeters/simbody/commit/7e43ab0fa4f808f11bf9385867002b359cf8dd36.diff?full_index=1"
    sha256 "2148108fc41d78fa81bb1102a14fa83f2bc643f788625a7b335daa3fa4e49740"
  end

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
  end
end
