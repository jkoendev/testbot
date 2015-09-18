#!/bin/bash
set -e

mypwd=`pwd`

svn co http://llvm.org/svn/llvm-project/llvm/tags/RELEASE_342/final/ llvm
cd llvm/tools
svn co http://llvm.org/svn/llvm-project/cfe/tags/RELEASE_342/final/ clang
cd ../..
mkdir build
cd build

cmake -DCMAKE_BUILD_TYPE=Release -DCMAKE_INSTALL_PREFIX="$mypwd/install" ../llvm
make clang-tblgen install -j2
cp bin/clang-tblgen "$mypwd/install/bin"

pushd ../install && tar -cvf $mypwd/clang_osx.tar.gz . && popd

cd $mypwd
export PYTHONPATH="$PYTHONPATH:$mypwd/helpers" && python -c "from restricted import *; upload('clang_osx.tar.gz')"