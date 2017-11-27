class IgnitionRendering < Formula
  desc "Common libraries for robotics applications. Rendering Library"
  homepage "https://bitbucket.org/ignitionrobotics/ign-rendering"
  url "https://bitbucket.org/ignitionrobotics/ign-rendering/get/ca7e2c8d7755131c9374c99a1df41c6eee415739.tar.gz"
  version "0.0.0~20170721~35b9bae"
  sha256 "4d2bde8f525d9220d66d972e1915e9f65527f4bc182f1ee450e085663e4db0ae"

  head "https://bitbucket.org/ignitionrobotics/ign-rendering", :branch => "default", :using => :hg

  #bottle do
  #  rebuild 1
  #  root_url "http://gazebosim.org/distributions/ign-rendering/releases"
  #  sha256 "a435130d701ebdaa58bd29833a26d53c612ae2163a195b0124ad71f0e54675d8" => :high_sierra
  #  sha256 "8660bbd506869aebc3c01114af9fa651d4ee67eaa9259748a7fc4204aeb01c08" => :sierra
  #  sha256 "ab9346c2e57d496cc71275d44f6091c6e0792913ca5cc1c88af97e5f099bb37a" => :el_capitan
  #end

  depends_on "cmake" => :build

  depends_on "freeimage"
  depends_on "ignition-common0"
  depends_on "ignition-math4"
  depends_on "ogre1.9"

  depends_on "pkg-config" => :run

  def install
    system "cmake", ".", *std_cmake_args
    system "make", "install"
  end

  test do
    (testpath/"test.cpp").write <<-EOS.undent
    #include <ignition/common/Console.hh>
	#include <ignition/common/Image.hh>

	#include "ignition/rendering/Camera.hh"
	#include "ignition/rendering/Image.hh"
	#include "ignition/rendering/PixelFormat.hh"
	#include "ignition/rendering/RenderEngine.hh"
	#include "ignition/rendering/RenderingIface.hh"
	#include "ignition/rendering/Scene.hh"

	using namespace ignition;
	using namespace rendering;

	int main()
	{
	  // override and make sure not to look for resources in installed share dir
	  std::string projectSrcPath = PROJECT_SOURCE_PATH;
	  std::string env = "IGN_RENDERING_RESOURCE_PATH=" +
		  common::joinPaths(projectSrcPath, "src");
	  putenv(const_cast<char *>(env.c_str()));

	  // create and populate scene
	  RenderEngine *engine = rendering::engine(_renderEngine);
	  if (!engine)
	  {
		igndbg << "Engine '" << _renderEngine
				  << "' is not supported" << std::endl;
		return;
	  }

	  // add resources in build dir
	  engine->AddResourcePath(
		  common::joinPaths(std::string(PROJECT_BUILD_PATH), "src"));

	  ScenePtr scene = engine->CreateScene("scene");
	  ASSERT_TRUE(scene != nullptr);
	  scene->SetAmbientLight(0.3, 0.3, 0.3);

	  VisualPtr root = scene->RootVisual();

	  CameraPtr camera = scene->CreateCamera();
    }
    EOS
    ENV.append_path "PKG_CONFIG_PATH", "#{Formula["qt"].opt_lib}/pkgconfig"
    system "pkg-config", "ignition-rendering"
    cflags   = `pkg-config --cflags ignition-rendering`.split(" ")
    ldflags  = `pkg-config --libs ignition-rendering`.split(" ")
    system ENV.cc, "test.cpp",
                   *cflags,
                   *ldflags,
                   "-lc++",
                   "-o", "test"
    system "./test"
  end
end
