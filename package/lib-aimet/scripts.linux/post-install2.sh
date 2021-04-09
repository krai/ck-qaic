#!/bin/bash

# Make sure we can reach our libraries via lib/ even if they were originally put into lib64/

cp -r ${INSTALL_DIR}/obj ${INSTALL_DIR}/install
