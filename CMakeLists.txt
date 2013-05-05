cmake_minimum_required (VERSION 2.8)
cmake_policy (VERSION 2.8)

project(dafioc)

set (PROJECT_SOURCE src)
set (PROJECT_TEST test)
set (PROJECT_PO po)
set (PROJECT_RESOURCE data)


list (APPEND CMAKE_MODULE_PATH
    ${CMAKE_SOURCE_DIR}/cmake/
    ${CMAKE_SOURCE_DIR}/cmake/gir
    ${CMAKE_SOURCE_DIR}/cmake/vala
)

#set (RESOURCES_DIR ${CMAKE_INSTALL_PREFIX}/share/daf/)
#set (GETTEXT_PACKAGE dafioc)

#configure_file (${CMAKE_SOURCE_DIR}/${PROJECT_RESOURCE}/config.h.cmake
#                ${CMAKE_BINARY_DIR}/${PROJECT_RESOURCE}/config.h)

#add_subdirectory (${PROJECT_PO})
add_subdirectory (${PROJECT_SOURCE})

#set (DO_NOT_BUILD_TEST  "")

IF (NOT DEFINED DO_NOT_BUILD_TEST)
    MESSAGE ("Building Unit Tests")
    enable_testing (true)
    add_subdirectory (${PROJECT_TEST})
ENDIF ()

