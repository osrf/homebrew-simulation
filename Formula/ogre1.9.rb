class Ogre19 < Formula
  desc "Scene-oriented 3D engine written in c++"
  homepage "https://ogrecave.github.io/ogre/"
  url "https://osrf-distributions.s3.amazonaws.com/ogre/releases/sinbad-ogre-108ab0bcc696.tar.bz2"
  version "1.9-20160714-108ab0bcc69603dba32c0ffd4bbbc39051f421c9"
  sha256 "3ca667b959905b290d782d7f0808e35d075c85db809d3239018e4e10e89b1721"
  license "MIT"
  revision 12

  # head "https://github.com/OGRECave/ogre.git", branch: "master"

  option "with-cg"

  depends_on "cmake" => :build
  depends_on "boost"
  depends_on "doxygen"
  depends_on "freeimage"
  depends_on "freetype"
  depends_on "libx11"
  depends_on "libzzip"
  depends_on "tbb"

  patch do
    url "https://gist.githubusercontent.com/marvinosswald/0e981e918aeee4403e9a0790c6f32cdd/raw/5d295499255867064ace8c4c41b2f31fd48d4576/gistfile1.txt"
    sha256 "62d33adbb3d46f9354ba9486226ee88649d7d7af0e26354f69c5cc777dd2ef86"
  end

  patch do
    url "https://gist.github.com/NikolausDemmel/2b11d1b49b35cd27a102/raw/bf4a4d16020821218f73db0d56aa111ab2fde679/fix-1.9-HEAD.diff"
    sha256 "15ecd1f12266918650ea789e2f96da4b0ef1a96076d7a671d3c56d98e2459712"
  end

  patch do
    # retain osx cocoa window
    url "https://gist.githubusercontent.com/NikolausDemmel/927bd7bb3f14c1788599/raw/c9a5ba88b758e80d3f46511629c4e8026b92c462/ogre1.9.patch"
    sha256 "e82d842138f7f5ff4637ed313d1140c3b868c8425d4cdba7a71e0a9d7f7e0fd6"
  end

  patch do
    # disable building samples if ois is not available
    url "https://gist.githubusercontent.com/iche033/68349eebfc436e484b70e6e3508ae27b/raw/d96227cd79ed1d63f051689a18c95a1c174a4efa/ogre-1.9-ois.patch"
    sha256 "7ad630740217ccb9f48898507e9c6713dcd37a677a9669cdc16ef39afbf68826"
  end

  # On macOS 26+ (Tahoe), Apple removed legacy Carbon and AGL frameworks from the SDK.
  # AGL was used only for Carbon-based contexts and PBuffers, which are 32-bit only.
  # Guard Carbon/AGL with #ifndef __LP64__, remove Carbon link flag, ensure Cocoa is
  # default on 64-bit, and ensure current OpenGL context on background rendering threads.
  patch :DATA

  patch do
    # backport cocoa window fix to support contents scaling factor (for retina displays)
    url "https://gist.githubusercontent.com/iche033/e0080a592c890cc9a4fce31f6863a5ed/raw/875ae8ad1d9f0eaa271fd44eab8e0979bac74119/ogre-1.9-cocoa_window_scale.patch"
    sha256 "c20c288530ea4d11b37f9c8b30cb43c89722c85eac0af3b6520cd89c37014e5b"
  end

  patch do
    # add libc++ flag
    url "https://gist.githubusercontent.com/iche033/e2b152d9df080b21f71ba3b65aa39922/raw/5397fa149c7570c17f2d78421d44b12dfa175387/ogre-1.9-cxx_flags.patch"
    sha256 "7dc77285029c34b4a6adb52b0d4b9c40578526a5e9764d0a7091c6a4cb63fa78"
  end

  patch do
    # fix FindOGRE.cmake for non-framework builds
    url "https://gist.githubusercontent.com/iche033/2b5e2ba31436881f1db29f9b60c7a5b2/raw/b6ab953ebd82127ad1177744f367a36e059312a9/ogre-1.9-findogre.patch"
    sha256 "7ca6f549fbdff7b7fc334f06da4547e071ec0e3f2733897fc6ef0d2bfa1716a3"
  end

  patch do
    # fix for boost 1.65
    url "https://github.com/OGRECave/ogre/commit/cade48b4c2215dd77ea74b7aa219a22c2a5d6654.patch?full_index=1"
    sha256 "d30c9a941b436c920cdb7a56e870e6a07921d1188ba3e0d8934323fdd28fc7c2"
  end

  patch do
    # fix for boost 1.67
    url "https://github.com/OGRECave/ogre/commit/2371c8d001725190a9cda62dc5df282cde78f951.patch?full_index=1"
    sha256 "28d418f7c978bedcf26c7a53c0f621fd5d9a2f27e5b838ea03af00e062f65470"
  end

  # fix for finding ZZip
  patch do
    url "https://github.com/scpeters/ogre/commit/8fcfe0885e6bd98d971250d4a3fb9a23e3743dfd.patch?full_index=1"
    sha256 "3a69a4ed9e86887d3a23b0882c9868e994ab710205bb2e4b87204a8c89f1a3c5"
  end

  # fix for m1 cpu arch
  patch do
    url "https://github.com/scpeters/ogre/commit/c39b6df49618773357da0b54437f351b57168d12.patch?full_index=1"
    sha256 "fa8dc20d5978d1ff1402a4df890a6fa0ca1fec6ec73f00154f7484820516b071"
  end

  # fix for OgreUTFString.h on newer clang
  patch do
    url "https://gist.githubusercontent.com/mrpollo/70a1fa1413d52227d0f9b5b2aa934442/raw/974f144e4c17d623f4bf90258876b38a90ef6018/ogre1.9-macos15-utfstring-fix.patch"
    sha256 "01c35413f9b544cc67282709614065af5826a9a450d039a3027ff3819aaaab8c"
  end

  def install
    cmake_args = [
      "-DCMAKE_CXX_STANDARD='14'",
      "-DOGRE_BUILD_DOCS:BOOL=FALSE",
      "-DOGRE_BUILD_LIBS_AS_FRAMEWORKS=OFF",
      "-DOGRE_BUILD_SAMPLES:BOOL=FALSE",
      "-DOGRE_FULL_RPATH:BOOL=FALSE",
      "-DOGRE_INSTALL_DOCS:BOOL=FALSE",
      "-DOGRE_INSTALL_SAMPLES:BOOL=FALSE",
      "-DOGRE_INSTALL_SAMPLES_SOURCE:BOOL=FALSE",
      "-DCMAKE_POLICY_VERSION_MINIMUM=3.5",
      "-DOGRE_STRING_USE_UTF16=OFF",
      "-DCMAKE_MACOSX_RPATH=ON",
      "-DCMAKE_INSTALL_RPATH=#{lib}",
    ]
    cmake_args << "-DOGRE_BUILD_PLUGIN_CG=OFF" if build.without? "cg"
    cmake_args.concat(std_cmake_args)
    cmake_args << ".."

    mkdir "build" do
      system "cmake", *cmake_args
      system "make", "install"
    end

    # Put these cmake files where Debian puts them
    (share/"OGRE/cmake/modules").install Dir[prefix/"CMake/*.cmake"]
    rmdir prefix/"CMake"

    # This is necessary because earlier versions of Ogre seem to have created
    # plugins with "lib" prefix and software like "rviz" now has Mac
    # specific code that looks for the plugins with "lib" prefix. Hence we add
    # symlinks with the "lib" prefix manually, but their use is deprecated.
    Dir.glob(lib/"OGRE/*.dylib") do |path|
      filename = File.basename(path)
      symlink path, lib/"OGRE/lib#{filename}"
    end
  end

  test do
    (testpath/"test.mesh.xml").write <<-EOS
      <mesh>
        <submeshes>
          <submesh material="BaseWhite" usesharedvertices="false" use32bitindexes="false" operationtype="triangle_list">
            <faces count="1">
              <face v1="0" v2="1" v3="2" />
            </faces>
            <geometry vertexcount="3">
              <vertexbuffer positions="true" normals="false" texture_coords="0">
                <vertex>
                  <position x="-50" y="-50" z="50" />
                </vertex>
                <vertex>
                  <position x="-50" y="-50" z="-50" />
                </vertex>
                <vertex>
                  <position x="50" y="-50" z="-50" />
                </vertex>
              </vertexbuffer>
            </geometry>
          </submesh>
        </submeshes>
        <submeshnames>
          <submeshname name="submesh0" index="0" />
        </submeshnames>
      </mesh>
    EOS
    system "#{bin}/OgreXMLConverter", "test.mesh.xml"
    system "du", "-h", "./test.mesh"
    # check for Xcode frameworks in bottle
    cmd_not_grep_xcode = "! grep -rnI 'Applications[/]Xcode' #{prefix}"
    system cmd_not_grep_xcode
  end
end

__END__
diff --git a/RenderSystems/GL/CMakeLists.txt b/RenderSystems/GL/CMakeLists.txt
index d1afd2b..431dc3b 100644
--- a/RenderSystems/GL/CMakeLists.txt
+++ b/RenderSystems/GL/CMakeLists.txt
@@ -109,7 +109,7 @@ endif ()
 
 if (APPLE)
     set_target_properties(RenderSystem_GL PROPERTIES
-        LINK_FLAGS "-framework Cocoa -framework Carbon -framework OpenGL")
+        LINK_FLAGS "-framework Cocoa -framework OpenGL")
 endif ()
 
 ogre_config_framework(RenderSystem_GL)
diff --git a/RenderSystems/GL/include/OSX/OgreOSXCarbonContext.h b/RenderSystems/GL/include/OSX/OgreOSXCarbonContext.h
index 05b6642..00de4e1 100644
--- a/RenderSystems/GL/include/OSX/OgreOSXCarbonContext.h
+++ b/RenderSystems/GL/include/OSX/OgreOSXCarbonContext.h
@@ -28,6 +28,9 @@ THE SOFTWARE.
 #ifndef __OgreOSXCarbonContext_H__
 #define __OgreOSXCarbonContext_H__
 
+// 64-bit Mac OS X doesn't support Carbon UI API
+#ifndef __LP64__
+
 #include "OgreOSXContext.h"
 #include <AGL/agl.h>
 #include <OpenGL/OpenGL.h>
@@ -68,3 +71,5 @@ namespace Ogre {
 }
 
 #endif
+
+#endif
diff --git a/RenderSystems/GL/include/OSX/OgreOSXRenderTexture.h b/RenderSystems/GL/include/OSX/OgreOSXRenderTexture.h
index 4677038..5be6c28 100644
--- a/RenderSystems/GL/include/OSX/OgreOSXRenderTexture.h
+++ b/RenderSystems/GL/include/OSX/OgreOSXRenderTexture.h
@@ -28,6 +28,9 @@ THE SOFTWARE.
 #ifndef __OSXRenderTexture_H__
 #define __OSXRenderTexture_H__
 
+// 64-bit Mac OS X doesn't support Carbon / AGL
+#ifndef __LP64__
+
 #include "OgrePrerequisites.h"
 
 #include "OgreGLPBuffer.h"
@@ -53,5 +56,8 @@ namespace Ogre
 		OSXCarbonContext* mContext;
     };
 }
+
+#endif
+
 #endif
 
diff --git a/RenderSystems/GL/include/OgreGLPrerequisites.h b/RenderSystems/GL/include/OgreGLPrerequisites.h
index 405dc34..86b43f8 100644
--- a/RenderSystems/GL/include/OgreGLPrerequisites.h
+++ b/RenderSystems/GL/include/OgreGLPrerequisites.h
@@ -70,6 +70,7 @@ namespace Ogre {
 #   define GL_GLEXT_PROTOTYPES
 #elif OGRE_PLATFORM == OGRE_PLATFORM_APPLE
 #   include <GL/glew.h>
+#   include <OpenGL/OpenGL.h>
 #   include <OpenGL/glu.h>
 #endif
 
diff --git a/RenderSystems/GL/include/OgreGLRenderSystem.h b/RenderSystems/GL/include/OgreGLRenderSystem.h
index d1eb64f..023851e 100644
--- a/RenderSystems/GL/include/OgreGLRenderSystem.h
+++ b/RenderSystems/GL/include/OgreGLRenderSystem.h
@@ -529,6 +529,7 @@ namespace Ogre {
         void _unregisterContext(GLContext *context);
 		/** Returns the main context */
 		GLContext* _getMainContext() {return mMainContext;} 
+		void _ensureContextCurrent();
 
 		/// @copydoc RenderSystem::getDisplayMonitorCount
 		unsigned int getDisplayMonitorCount() const;
diff --git a/RenderSystems/GL/src/OSX/OgreOSXCarbonContext.cpp b/RenderSystems/GL/src/OSX/OgreOSXCarbonContext.cpp
index 3620471..96fc203 100644
--- a/RenderSystems/GL/src/OSX/OgreOSXCarbonContext.cpp
+++ b/RenderSystems/GL/src/OSX/OgreOSXCarbonContext.cpp
@@ -26,6 +26,9 @@ THE SOFTWARE.
 -----------------------------------------------------------------------------
 */
 
+// 64-bit Mac OS X doesn't support Carbon UI API
+#ifndef __LP64__
+
 #include "OgreOSXCarbonContext.h"
 #include "OgreLogManager.h"
 
@@ -69,3 +72,5 @@ namespace Ogre
 	}
 
 }
+
+#endif
diff --git a/RenderSystems/GL/src/OSX/OgreOSXGLSupport.mm b/RenderSystems/GL/src/OSX/OgreOSXGLSupport.mm
index a9d2b11..7e148d0 100644
--- a/RenderSystems/GL/src/OSX/OgreOSXGLSupport.mm
+++ b/RenderSystems/GL/src/OSX/OgreOSXGLSupport.mm
@@ -393,8 +393,13 @@ RenderWindow* OSXGLSupport::newWindow( const String &name, unsigned int width, u
 	bool fullScreen, const NameValuePairList *miscParams )
 {
 	// Does the user want Cocoa or Carbon, default to Carbon...
+#ifndef __LP64__
 	mAPI = "carbon";
 	mContextType = "CGL";
+#else
+	mAPI = "cocoa";
+	mContextType = "NSOpenGL";
+#endif
 	
 	if(miscParams)
 	{
@@ -473,7 +478,11 @@ void* OSXGLSupport::getProcAddress( const String& procname )
 
 bool OSXGLSupport::supportsPBuffers()
 {
+#ifndef __LP64__
 	return true;
+#else
+	return false;
+#endif
 }
 
 GLPBuffer* OSXGLSupport::createPBuffer(PixelComponentType format, uint32 width, uint32 height)
@@ -483,7 +492,11 @@ GLPBuffer* OSXGLSupport::createPBuffer(PixelComponentType format, uint32 width,
 //	if(mContextType == "CGL")
 //		return OGRE_NEW OSXCGLPBuffer(format, width, height);
 //	else
+#ifndef __LP64__
 		return OGRE_NEW OSXPBuffer(format, width, height);
+#else
+		return NULL;
+#endif
 }
 
 #if defined(MAC_OS_X_VERSION_10_6) && MAC_OS_X_VERSION_MIN_REQUIRED >= MAC_OS_X_VERSION_10_6
diff --git a/RenderSystems/GL/src/OSX/OgreOSXRenderTexture.cpp b/RenderSystems/GL/src/OSX/OgreOSXRenderTexture.cpp
index 37434e6..ac3c662 100644
--- a/RenderSystems/GL/src/OSX/OgreOSXRenderTexture.cpp
+++ b/RenderSystems/GL/src/OSX/OgreOSXRenderTexture.cpp
@@ -25,6 +25,9 @@ OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
 THE SOFTWARE.
 -----------------------------------------------------------------------------
 */
+// 64-bit Mac OS X doesn't support Carbon / AGL
+#ifndef __LP64__
+
 #include "OgreStableHeaders.h"
 
 #include "OgreException.h"
@@ -89,3 +92,5 @@ namespace Ogre
 	}
 }
 
+#endif
+
diff --git a/RenderSystems/GL/src/OgreGLFrameBufferObject.cpp b/RenderSystems/GL/src/OgreGLFrameBufferObject.cpp
index 3e29740..79561ec 100755
--- a/RenderSystems/GL/src/OgreGLFrameBufferObject.cpp
+++ b/RenderSystems/GL/src/OgreGLFrameBufferObject.cpp
@@ -31,6 +31,7 @@ THE SOFTWARE.
 #include "OgreLogManager.h"
 #include "OgreStringConverter.h"
 #include "OgreRoot.h"
+#include "OgreGLRenderSystem.h"
 #include "OgreGLHardwarePixelBuffer.h"
 #include "OgreGLFBORenderTexture.h"
 #include "OgreGLDepthBuffer.h"
@@ -41,6 +42,11 @@ namespace Ogre {
     GLFrameBufferObject::GLFrameBufferObject(GLFBOManager *manager, uint fsaa):
         mManager(manager), mNumSamples(fsaa)
     {
+#if OGRE_PLATFORM == OGRE_PLATFORM_APPLE
+        GLRenderSystem* rs = static_cast<GLRenderSystem*>(Root::getSingleton().getRenderSystem());
+        if (rs)
+            rs->_ensureContextCurrent();
+#endif
         // Generate framebuffer object
         glGenFramebuffersEXT(1, &mFB);
 		// check multisampling
diff --git a/RenderSystems/GL/src/OgreGLHardwareIndexBuffer.cpp b/RenderSystems/GL/src/OgreGLHardwareIndexBuffer.cpp
index a4db506..2c5adeb 100644
--- a/RenderSystems/GL/src/OgreGLHardwareIndexBuffer.cpp
+++ b/RenderSystems/GL/src/OgreGLHardwareIndexBuffer.cpp
@@ -29,6 +29,8 @@ THE SOFTWARE.
 #include "OgreGLHardwareBufferManager.h"
 #include "OgreException.h"
 #include "OgreGLStateCacheManager.h"
+#include "OgreGLRenderSystem.h"
+#include "OgreRoot.h"
 
 namespace Ogre {
 
@@ -37,6 +39,11 @@ namespace Ogre {
         size_t numIndexes, HardwareBuffer::Usage usage, bool useShadowBuffer)
         : HardwareIndexBuffer(mgr, idxType, numIndexes, usage, false, useShadowBuffer)
     {
+#if OGRE_PLATFORM == OGRE_PLATFORM_APPLE
+        GLRenderSystem* rs = static_cast<GLRenderSystem*>(Root::getSingleton().getRenderSystem());
+        if (rs)
+            rs->_ensureContextCurrent();
+#endif
         glGenBuffersARB( 1, &mBufferId );
 
         if (!mBufferId)
diff --git a/RenderSystems/GL/src/OgreGLHardwareOcclusionQuery.cpp b/RenderSystems/GL/src/OgreGLHardwareOcclusionQuery.cpp
index e5746ad..60d1f75 100644
--- a/RenderSystems/GL/src/OgreGLHardwareOcclusionQuery.cpp
+++ b/RenderSystems/GL/src/OgreGLHardwareOcclusionQuery.cpp
@@ -28,6 +28,8 @@ THE SOFTWARE.
 
 #include "OgreGLHardwareOcclusionQuery.h"
 #include "OgreException.h"
+#include "OgreRoot.h"
+#include "OgreGLRenderSystem.h"
 
 namespace Ogre {
 
@@ -48,6 +50,11 @@ namespace Ogre {
   */
 GLHardwareOcclusionQuery::GLHardwareOcclusionQuery() 
 { 
+#if OGRE_PLATFORM == OGRE_PLATFORM_APPLE
+    GLRenderSystem* rs = static_cast<GLRenderSystem*>(Root::getSingleton().getRenderSystem());
+    if (rs)
+        rs->_ensureContextCurrent();
+#endif
 	// Check for hardware occlusion support
     if(GLEW_VERSION_1_5 || GLEW_ARB_occlusion_query)
 	{
diff --git a/RenderSystems/GL/src/OgreGLHardwarePixelBuffer.cpp b/RenderSystems/GL/src/OgreGLHardwarePixelBuffer.cpp
index 96a36a1..71e232d 100644
--- a/RenderSystems/GL/src/OgreGLHardwarePixelBuffer.cpp
+++ b/RenderSystems/GL/src/OgreGLHardwarePixelBuffer.cpp
@@ -35,6 +35,7 @@ THE SOFTWARE.
 #include "OgreBitwise.h"
 #include "OgreGLFBORenderTexture.h"
 #include "OgreRoot.h"
+#include "OgreGLRenderSystem.h"
 #include "OgreGLStateCacheManager.h"
 
 namespace Ogre {
@@ -667,6 +668,11 @@ void GLTextureBuffer::blitFromTexture(GLTextureBuffer *src, const Image::Box &sr
     GLint oldfb;
     glGetIntegerv(GL_FRAMEBUFFER_BINDING_EXT, &oldfb);
     
+#if OGRE_PLATFORM == OGRE_PLATFORM_APPLE
+    GLRenderSystem* rs = static_cast<GLRenderSystem*>(Root::getSingleton().getRenderSystem());
+    if (rs)
+        rs->_ensureContextCurrent();
+#endif
     /// Set up temporary FBO
     glBindFramebufferEXT(GL_FRAMEBUFFER_EXT, fboMan->getTemporaryFBO());
     
@@ -876,6 +882,11 @@ GLRenderBuffer::GLRenderBuffer(GLenum format, uint32 width, uint32 height, GLsiz
     GLHardwarePixelBuffer(width, height, 1, GLPixelUtil::getClosestOGREFormat(format),HBU_WRITE_ONLY),
     mRenderbufferID(0)
 {
+#if OGRE_PLATFORM == OGRE_PLATFORM_APPLE
+    GLRenderSystem* rs = static_cast<GLRenderSystem*>(Root::getSingleton().getRenderSystem());
+    if (rs)
+        rs->_ensureContextCurrent();
+#endif
     mGLInternalFormat = format;
     /// Generate renderbuffer
     glGenRenderbuffersEXT(1, &mRenderbufferID);
diff --git a/RenderSystems/GL/src/OgreGLHardwareVertexBuffer.cpp b/RenderSystems/GL/src/OgreGLHardwareVertexBuffer.cpp
index ecf44f1..c43d5b8 100644
--- a/RenderSystems/GL/src/OgreGLHardwareVertexBuffer.cpp
+++ b/RenderSystems/GL/src/OgreGLHardwareVertexBuffer.cpp
@@ -30,6 +30,8 @@ THE SOFTWARE.
 #include "OgreException.h"
 #include "OgreLogManager.h"
 #include "OgreGLStateCacheManager.h"
+#include "OgreGLRenderSystem.h"
+#include "OgreRoot.h"
 
 namespace Ogre {
 
@@ -38,6 +40,11 @@ namespace Ogre {
         size_t numVertices, HardwareBuffer::Usage usage, bool useShadowBuffer)
         : HardwareVertexBuffer(mgr, vertexSize, numVertices, usage, false, useShadowBuffer)
     {
+#if OGRE_PLATFORM == OGRE_PLATFORM_APPLE
+        GLRenderSystem* rs = static_cast<GLRenderSystem*>(Root::getSingleton().getRenderSystem());
+        if (rs)
+            rs->_ensureContextCurrent();
+#endif
         glGenBuffersARB( 1, &mBufferId );
 
         if (!mBufferId)
@@ -123,6 +130,11 @@ namespace Ogre {
                     static_cast<GLHardwareBufferManagerBase*>(mMgr)->getStateCacheManager()->deleteGLBuffer(GL_ARRAY_BUFFER_ARB, mBufferId);
                     mBufferId = 0;
                     
+#if OGRE_PLATFORM == OGRE_PLATFORM_APPLE
+                    GLRenderSystem* rs = static_cast<GLRenderSystem*>(Root::getSingleton().getRenderSystem());
+                    if (rs)
+                        rs->_ensureContextCurrent();
+#endif
                     glGenBuffersARB( 1, &mBufferId );
                     
                     static_cast<GLHardwareBufferManagerBase*>(mMgr)->getStateCacheManager()->bindGLBuffer(GL_ARRAY_BUFFER_ARB, mBufferId);
diff --git a/RenderSystems/GL/src/OgreGLRenderSystem.cpp b/RenderSystems/GL/src/OgreGLRenderSystem.cpp
index 4a56da8..8fd0f66 100644
--- a/RenderSystems/GL/src/OgreGLRenderSystem.cpp
+++ b/RenderSystems/GL/src/OgreGLRenderSystem.cpp
@@ -3516,6 +3516,19 @@ GL_RGB_SCALE : GL_ALPHA_SCALE, 1);
 		mStateCacheManager->setStencilMask(mStencilWriteMask);
 
 	}
+	//---------------------------------------------------------------------
+	void GLRenderSystem::_ensureContextCurrent()
+	{
+#if OGRE_PLATFORM == OGRE_PLATFORM_APPLE
+		if (CGLGetCurrentContext() == NULL)
+		{
+			GLContext* ctx = mCurrentContext ? mCurrentContext : mMainContext;
+			if (ctx)
+				ctx->setCurrent();
+		}
+#endif
+	}
+
 	//---------------------------------------------------------------------
 	void GLRenderSystem::_setRenderTarget(RenderTarget *target)
 	{
@@ -3529,7 +3542,11 @@ GL_RGB_SCALE : GL_ALPHA_SCALE, 1);
 			// Switch context if different from current one
 			GLContext *newContext = 0;
 			target->getCustomAttribute(GLRenderTexture::CustomAttributeString_GLCONTEXT, &newContext);
+#if OGRE_PLATFORM == OGRE_PLATFORM_APPLE
+			if(newContext && (mCurrentContext != newContext || CGLGetCurrentContext() == NULL))
+#else
 			if(newContext && mCurrentContext != newContext) 
+#endif
 			{
 				_switchContext(newContext);
 			}
+#if OGRE_PLATFORM == OGRE_PLATFORM_APPLE
+			else
+			{
+				_ensureContextCurrent();
+			}
+#endif
diff --git a/RenderSystems/GL/src/OgreGLRenderToVertexBuffer.cpp b/RenderSystems/GL/src/OgreGLRenderToVertexBuffer.cpp
index 64bd6da..322701a 100644
--- a/RenderSystems/GL/src/OgreGLRenderToVertexBuffer.cpp
+++ b/RenderSystems/GL/src/OgreGLRenderToVertexBuffer.cpp
@@ -33,6 +33,7 @@ THE SOFTWARE.
 #include "OgreSceneManager.h"
 #include "OgreRoot.h"
 #include "OgreRenderSystem.h"
+#include "OgreGLRenderSystem.h"
 #include "OgreGLSLLinkProgramManager.h"
 #include "OgreStringConverter.h"
 
@@ -111,6 +112,11 @@ namespace Ogre {
 		mVertexBuffers[1].setNull();
 
 		 // create query objects
+#if OGRE_PLATFORM == OGRE_PLATFORM_APPLE
+		GLRenderSystem* rs = static_cast<GLRenderSystem*>(Root::getSingleton().getRenderSystem());
+		if (rs)
+			rs->_ensureContextCurrent();
+#endif
 		glGenQueries(1, &mPrimitivesDrawnQuery);
 	}
 //-----------------------------------------------------------------------------
diff --git a/RenderSystems/GL/src/OgreGLTexture.cpp b/RenderSystems/GL/src/OgreGLTexture.cpp
index fde05c8..9d7e511 100644
--- a/RenderSystems/GL/src/OgreGLTexture.cpp
+++ b/RenderSystems/GL/src/OgreGLTexture.cpp
@@ -37,6 +37,7 @@ THE SOFTWARE.
 #include "OgreCamera.h"
 #include "OgreException.h"
 #include "OgreRoot.h"
+#include "OgreGLRenderSystem.h"
 #include "OgreCodec.h"
 #include "OgreImageCodec.h"
 #include "OgreStringConverter.h"
@@ -103,6 +104,11 @@ namespace Ogre {
 	//* Creation / loading methods ********************************************
 	void GLTexture::createInternalResourcesImpl(void)
     {
+#if OGRE_PLATFORM == OGRE_PLATFORM_APPLE
+        GLRenderSystem* rs = static_cast<GLRenderSystem*>(Root::getSingleton().getRenderSystem());
+        if (rs)
+            rs->_ensureContextCurrent();
+#endif
 		if (!GLEW_VERSION_1_2 && mTextureType == TEX_TYPE_3D)
 			OGRE_EXCEPT(Exception::ERR_NOT_IMPLEMENTED, 
 				"3D Textures not supported before OpenGL 1.2", 
