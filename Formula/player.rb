class Player < Formula
  desc "Cross-platform robot device interface & server"
  homepage "http://playerstage.sourceforge.net"
  url "https://downloads.sourceforge.net/project/playerstage/Player/3.0.2/player-3.0.2.tar.gz"
  sha256 "25f93185aeae969adcd2f8ec2849f7773e1715a901e0ea365c777368a5c61343"
  head "http://svn.code.sf.net/p/playerstage/svn/code/player/trunk"

  depends_on "cmake" => :build

  # Fix compilation errors reported in #19
  patch :DATA

  def install
    # swig bindings are broken
    # https://github.com/osrf/homebrew-simulation/issues/76
    # https://github.com/playerproject/player/issues/3
    cmake_args = std_cmake_args
    cmake_args << "-DBUILD_RUBY_BINDINGS=0"
    cmake_args << "-DBUILD_PYTHONC_BINDINGS=0"

    system "cmake", ".", *cmake_args
    system "make", "install"
  end
end

__END__
diff -u a/client_libs/libplayerc++/playerclient.cc b/client_libs/libplayerc++/playerclient.cc
--- a/client_libs/libplayerc++/playerclient.cc	2009-02-17 19:53:04.000000000 -0800
+++ b/client_libs/libplayerc++/playerclient.cc	2014-06-01 00:08:39.000000000 -0700
@@ -168,7 +168,11 @@
       Read();
     };
     boost::xtime xt;
+#if BOOST_VERSION < 105000
     boost::xtime_get(&xt, boost::TIME_UTC);
+#else
+    boost::xtime_get(&xt, boost::TIME_UTC_);
+#endif  // if BOOST_VERSION < 105000
     // we sleep for 0 seconds
     boost::thread::sleep(xt);
   }
diff -u a/server/drivers/mixed/rflex/rflex.cc b/server/drivers/mixed/rflex/rflex.cc
--- a/server/drivers/mixed/rflex/rflex.cc	2009-07-20 20:47:16.000000000 -0700
+++ b/server/drivers/mixed/rflex/rflex.cc	2014-05-31 03:19:16.000000000 -0700
@@ -316,7 +316,7 @@
 #include <libplayercore/playercore.h>
 #include <libplayerinterface/playerxdr.h>
 
-extern int               RFLEX::joy_control;
+int               RFLEX::joy_control;
 
 // help function to rotate sonar positions
 void SonarRotate(double heading, double x1, double y1, double t1, double *x2, double *y2, double *t2)
diff --git a/client_libs/libplayerc++/CMakeLists.txt b/client_libs/libplayerc++/CMakeLists.txt
index c7410ec..6c9737d 100644
--- a/client_libs/libplayerc++/CMakeLists.txt
+++ b/client_libs/libplayerc++/CMakeLists.txt
@@ -104,6 +104,10 @@ IF (BUILD_PLAYERCC)
                              "PlayerC++ client library will be built with Boost::Thread support.")
                         SET (boostThreadLib boost_thread${BOOST_LIB_SUFFIX})
                         PLAYERCC_ADD_LINK_LIB (${boostThreadLib})
+                        IF (APPLE)
+                          SET (boostSystemLib boost_system${BOOST_LIB_SUFFIX})
+                          PLAYERCC_ADD_LINK_LIB (${boostSystemLib})
+                        ENDIF (APPLE)
                         PLAYERCC_ADD_INCLUDE_DIR (${Boost_INCLUDE_DIR})
                         PLAYERCC_ADD_LINK_DIR (${Boost_LIBRARY_DIRS})
                         SET (boostIncludeDir ${Boost_INCLUDE_DIRS})
diff --git a/libplayercore/message.cc b/libplayercore/message.cc
index 29bb3be..c850c49 100644
--- a/libplayercore/message.cc
+++ b/libplayercore/message.cc
@@ -726,25 +726,25 @@ MessageQueue & QueuePointer::operator * ()
 }
 
 /// check if pointers are equal
-bool QueuePointer::operator == (const QueuePointer & rhs)
+bool QueuePointer::operator == (const QueuePointer & rhs) const
 {
   return rhs.Queue == Queue;
 }
 
 /// check if pointers are equal
-bool QueuePointer::operator == (void * pointer)
+bool QueuePointer::operator == (void * pointer) const
 {
   return Queue == pointer;
 }
 
 /// check if pointers are equal
-bool QueuePointer::operator != (const QueuePointer & rhs)
+bool QueuePointer::operator != (const QueuePointer & rhs) const
 {
   return rhs.Queue != Queue;
 }
 
 /// check if pointers are equal
-bool QueuePointer::operator != (void * pointer)
+bool QueuePointer::operator != (void * pointer) const
 {
   return Queue != pointer;
 }
diff --git a/libplayercore/message.h b/libplayercore/message.h
index 89b91f4..04fba44 100644
--- a/libplayercore/message.h
+++ b/libplayercore/message.h
@@ -91,13 +91,13 @@ class PLAYERCORE_EXPORT QueuePointer
 	/// retrieve underlying object for use
 	MessageQueue & operator * ();
 	/// check if pointers are equal
-	bool operator == (const QueuePointer & rhs);
+	bool operator == (const QueuePointer & rhs) const;
 	/// check if pointers are equal
-	bool operator == (void * pointer);
+	bool operator == (void * pointer) const;
 	/// check if pointers are equal
-	bool operator != (const QueuePointer & rhs);
+	bool operator != (const QueuePointer & rhs) const;
 	/// check if pointers are equal
-	bool operator != (void * pointer);
+	bool operator != (void * pointer) const;
 	
   private:
     /// Decrement ref count
