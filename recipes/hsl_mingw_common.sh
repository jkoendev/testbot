#!/bin/bash
#set -e

if [ -z "$SETUP" ]; then
  pushd $HOME/build
  slurp ipopt
  popd
  pushd restricted
  wget http://glaros.dtc.umn.edu/gkhome/fetch/sw/metis/OLD/metis-4.0.3.tar.gz
  tar -xvf coinhsl.tar.gz && cd coinhsl-2014.01.10 && tar -xvf ../metis-4.0.3.tar.gz
  sed -i "s/coinhsl/hsl/" configure.ac
  sed -i "s/coinhsl/hsl/g" Makefile.am
  echo "libhsl_la_LDFLAGS += -avoid-version" >> Makefile.am
  mv libcoinhsl.sym libhsl.sym
  mv coinhsl.pc.in hsl.pc.in
  sed -i "s/coinhsl/hsl/g" hsl.pc.in
  aclocal
  autoheader
  automake --add-missing
  automake
  autoconf

  ./configure --disable-static --enable-shared --host $compilerprefix --prefix=$mypwd/coinhsl-install LIBS="-L/home/travis/ipopt-install/lib" --with-blas="-lcoinblas -lcoinlapack -lcoinblas" CXXFLAGS="" FCFLAGS="-O2" CFLAGS="-O2" || cat config.log
  sed -i "s/deplibs_check_method=.*/deplibs_check_method=\"pass_all\"/" libtool

  make
  make install

  mkdir $mypwd/pack
  cd $mypwd/coinhsl-install/bin
  cp *.dll $mypwd/pack/
  pushd $mypwd/pack/
  gendef libhsl.dll - | tee  libhsl.def
  $compilerprefix-dlltool --dllname libhsl.dll -d libhsl.def  -l libhsl.lib
  popd
  cp /usr/lib/gcc/$compilerprefix/5.3-posix/*.dll $mypwd/pack || allowfail 1
  cp /usr/$compilerprefix/lib/*.dll $mypwd/pack || allowfail 1
  cp $MINGW_LIB/usr/lib/gcc/i686-w64-mingw32/4.9.4/*.dll $mypwd/pack || allowfail 1
  zip -j -r hsl$SUFFIXFILE $mypwd/pack/*.dll hsl$SUFFIXFILE $mypwd/pack/*.lib hsl$SUFFIXFILE $mypwd/pack/*.a
  
  slurp_put hsl$SUFFIXFILE
else
  fetch_zip hsl $SUFFIX
  export LD_LIBRARY_PATH=$LD_LIBRARY_PATH:$HOME/build/hsl
  export HSL=$HOME/build/hsl
  export casadi_build_flags="$casadi_build_flags -DWITH_HSL=ON"  
fi

