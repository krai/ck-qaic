#!/bin/bash
cd src
mkdir -p ./ThirdParty/googletest
pushd ./ThirdParty/googletest
git clone https://github.com/google/googletest.git -b release-1.8.0 googletest-release-1.8.0
popd
