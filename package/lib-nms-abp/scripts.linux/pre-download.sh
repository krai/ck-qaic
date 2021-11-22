#!/bin/bash
rm -rf ${INSTALL_DIR:-"EMPTY_FOLDER"}/*
mkdir -p "${INSTALL_DIR}/src"
cp -f ${ORIGINAL_PACKAGE_DIR}/CMakeLists.txt ${INSTALL_DIR}/src/
cp -f ${ORIGINAL_PACKAGE_DIR}/*.in ${INSTALL_DIR}/src/
cp -rf ${ORIGINAL_PACKAGE_DIR}/src ${INSTALL_DIR}/src/
cp -rf ${ORIGINAL_PACKAGE_DIR}/inc ${INSTALL_DIR}/src/
cp -rf ${ORIGINAL_PACKAGE_DIR}/data ${INSTALL_DIR}/src/
