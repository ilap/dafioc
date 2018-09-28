includedir=@DOLLAR@{prefix}/include

Name: @PKGNAME@
Description: DaF's IoC DI Module
Version: @VERSION@
Libs: -L@CMAKE_INSTALL_PREFIX@/lib -l@PKGNAME@
Cflags: -I@CMAKE_INSTALL_PREFIX@/include/@PKGNAME@
