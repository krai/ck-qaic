cmake_minimum_required (VERSION 3.9)
project (nms_abp VERSION 0.01 DESCRIPTION "NMS-ABP library for Object Detection")
include (GNUInstallDirs)

set(PUBLIC_INCLUDE_DIRECTORIES inc/) 
set(PUBLIC_DATA_DIRECTORIES data/) 

file(GLOB_RECURSE INCLUDE_FILES "inc/*.h*")
file(GLOB_RECURSE DATA_FILES "data/*.bin*")

add_library(nms_abp SHARED src/nms_abp.cxx)

set_target_properties(nms_abp PROPERTIES
    VERSION ${PROJECT_VERSION}
    SOVERSION 1
    PUBLIC_HEADER "${INCLUDE_FILES}"
)

configure_file(nms_abp.pc.in nms_abp.pc @ONLY)
target_include_directories(nms_abp PRIVATE inc)
target_include_directories(nms_abp PRIVATE src)

install(TARGETS nms_abp
    LIBRARY DESTINATION ${CMAKE_INSTALL_LIBDIR}
    PUBLIC_HEADER DESTINATION ${CMAKE_INSTALL_INCLUDEDIR}
)
install(FILES ${CMAKE_BINARY_DIR}/nms_abp.pc
    DESTINATION ${CMAKE_INSTALL_DATAROOTDIR}/pkgconfig)
install(FILES ${DATA_FILES}
    DESTINATION ${CMAKE_INSTALL_DATAROOTDIR}/)

