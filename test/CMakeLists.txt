set (UNIT_TEST unit_test)

set (VALA_SOURCES
    TestMain.vala
)

set (PKG_DEPS glib-2.0 gio-2.0 gee-1.0)

# set (CMAKE_VERBOSE_MAKEFILE ON)
set (CMAKE_FIND_LIBRARY_SUFFIXES .so)

# External Packages definitions.
set (EXTERN_PROJ dafunit)
set (EXTERN_SOURCE_DIR src)

set (INTERN_PROJ dafioc)
set (INTERN_SOURCE_DIR ${PROJECT_SOURCE})

include (ExternalProject)

ExternalProject_Add (${EXTERN_PROJ}
    #PREFIX ../../${EXTERN_PROJ}
    SOURCE_DIR ../../../${EXTERN_PROJ}
    BINARY_DIR ${CMAKE_BINARY_DIR}/${EXTERN_PROJ}/build
    INSTALL_DIR ""
    UPDATE_COMMAND ""
    PATCH_COMMAND ""
    INSTALL_COMMAND ""
)

ExternalProject_Get_Property(${EXTERN_PROJ} BINARY_DIR)
include_directories (${BINARY_DIR}/${EXTERN_SOURCE_DIR})
include_directories (${CMAKE_BINARY_DIR}/${INTERN_SOURCE_DIR})

# PkgConfig
find_package (PkgConfig)
find_package (GObjectIntrospection 0.9.12)
include (GObjectIntrospectionMacros)

pkg_check_modules(DEPS REQUIRED    ${PKG_DEPS})

set (CFLAGS ${DEPS_CFLAGS} ${DEPS_CFLAGS_OTHER})
add_definitions (${CFLAGS})
set (LIBS ${DEPS_LIBRARIES})
set(LIB_PATHS ${DEPS_LIBRARY_DIRS})
link_directories(${LIB_PATHS})

# Does not work set (ENV{PKG_CONFIG_PATH} ${EXTERNAL_BINARY_DIR}/src)
vala_precompile (VALA_C
        ${VALA_SOURCES}
    PACKAGES
        ${PKG_DEPS}
        posix
    CUSTOM_VAPIS
        ${CMAKE_BINARY_DIR}/${INTERN_SOURCE_DIR}/${INTERN_PROJ}.vapi
        ${BINARY_DIR}/${EXTERN_SOURCE_DIR}/${EXTERN_PROJ}.vapi
    OPTIONS
)

add_executable (${UNIT_TEST} ${VALA_C})

# Does not work add_dependencies (unit_test dafioc)
target_link_libraries(${UNIT_TEST} ${LIBS})
target_link_libraries(${UNIT_TEST} ${BINARY_DIR}/${EXTERN_SOURCE_DIR}/${CMAKE_FIND_LIBRARY_PREFIXES}${EXTERN_PROJ}${CMAKE_FIND_LIBRARY_SUFFIXES})
target_link_libraries(${UNIT_TEST} ${CMAKE_BINARY_DIR}/${INTERN_SOURCE_DIR}/${CMAKE_FIND_LIBRARY_PREFIXES}${INTERN_PROJ}${CMAKE_FIND_LIBRARY_SUFFIXES})
add_test(${UNIT_TEST} ${CMAKE_CURRENT_BINARY_DIR}/${UNIT_TEST})
