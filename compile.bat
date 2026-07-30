@echo off
set "ROOT_DIR=%~dp0"
set "ROOT_DIR=%ROOT_DIR:\=/%"

:: we should benchmark these flags
set "CFLAGS=-flto -O3 -DNDEBUG -march=native"
set "CXXFLAGS=-flto -O3 -DNDEBUG -march=native"

set CC=clang
set CXX=clang++

if exist zlib (
  cd zlib
  git pull
) else (
  git clone https://github.com/madler/zlib.git
  cd zlib
)
cmake --fresh -B build -G Ninja ^
  -DCMAKE_BUILD_TYPE=Release ^
  -DCMAKE_MSVC_RUNTIME_LIBRARY=MultiThreaded
ninja -C build
cmake --install build --prefix install
cd ..

if exist libpng (
  cd libpng
  git pull
) else (
  git clone https://github.com/pnggroup/libpng.git
  cd libpng
)
cmake --fresh -B build -G Ninja ^
  -DCMAKE_BUILD_TYPE=Release ^
  -DCMAKE_MSVC_RUNTIME_LIBRARY=MultiThreaded ^
  -DZLIB_INCLUDE_DIR="%ROOT_DIR%zlib/install/include" ^
  -DZLIB_LIBRARY="%ROOT_DIR%zlib/install/lib/zs.lib"
ninja -C build
cmake --install build --prefix install
cd ..

if exist libjpeg-turbo (
  cd libjpeg-turbo
  git pull
) else (
  git clone https://github.com/libjpeg-turbo/libjpeg-turbo.git
  cd libjpeg-turbo
)
cmake --fresh -B build -G Ninja ^
  -DCMAKE_BUILD_TYPE=Release ^
  -DCMAKE_MSVC_RUNTIME_LIBRARY=MultiThreaded
ninja -C build
cmake --install build --prefix install
cd ..

if exist Imath (
  cd Imath
  git pull
) else (
  git clone https://github.com/AcademySoftwareFoundation/Imath.git
  cd Imath
)
cmake --fresh -B build -G Ninja ^
  -DCMAKE_BUILD_TYPE=Release ^
  -DCMAKE_POLICY_DEFAULT_CMP0091=NEW ^
  -DCMAKE_MSVC_RUNTIME_LIBRARY=MultiThreaded ^
  -DBUILD_SHARED_LIBS=OFF ^
  -DCMAKE_INSTALL_PREFIX="%ROOT_DIR%Imath/install"
ninja -C build
cmake --install build --prefix install
cd ..

if exist openexr (
  cd openexr
  git pull
) else (
  git clone https://github.com/AcademySoftwareFoundation/openexr.git
  cd openexr
)
cmake --fresh -B build -G Ninja ^
  -DCMAKE_BUILD_TYPE=Release ^
  -DCMAKE_POLICY_DEFAULT_CMP0091=NEW ^
  -DCMAKE_MSVC_RUNTIME_LIBRARY=MultiThreaded ^
  -DBUILD_SHARED_LIBS=OFF ^
  -DOPENEXR_BUILD_TOOLS=OFF ^
  -DOPENEXR_BUILD_EXAMPLES=OFF ^
  -DBUILD_TESTING=OFF ^
  -DCMAKE_PREFIX_PATH="%ROOT_DIR%Imath/install" ^
  -DCMAKE_CXX_FLAGS="%CXXFLAGS% -msse4.1" ^
  -DCMAKE_C_FLAGS="%CFLAGS% -msse4.1" ^
  -DCMAKE_INSTALL_PREFIX="%ROOT_DIR%openexr/install"
ninja -C build
cmake --install build --prefix install
cd ..

set CHERE_INVOKING=1
(
echo pacman -S --noconfirm --needed base-devel git
echo if [ -d giflib ]; then
echo   cd giflib
echo   git pull
echo else
echo   git clone https://git.code.sf.net/p/giflib/code giflib
echo   cd giflib
echo fi
echo export PATH="/c/Program Files/LLVM/bin:$PATH"
echo export CC=clang
echo export CXX=clang++
echo export AR=llvm-ar
echo make libgif.a CFLAGS="-std=gnu99 -Wall -D_MT -Xclang --dependent-lib=libcmt %CFLAGS%"
) | C:\msys64\usr\bin\bash.exe -l

cmake --fresh -B build -G Ninja ^
  -DCMAKE_BUILD_TYPE=Release ^
  -DJPEGXL_STATIC=ON ^
  -DBUILD_TESTING=OFF ^
  -DJPEGXL_ENABLE_BENCHMARK=OFF ^
  -DJPEGXL_ENABLE_MANPAGES=OFF ^
  -DJPEGXL_ENABLE_OPENEXR=ON ^
  -DJPEGXL_ENABLE_TCMALLOC=OFF ^
  -DZLIB_INCLUDE_DIR="%ROOT_DIR%zlib/install/include" ^
  -DZLIB_LIBRARY="%ROOT_DIR%zlib/install/lib/zs.lib" ^
  -DPNG_PNG_INCLUDE_DIR="%ROOT_DIR%libpng/install/include" ^
  -DPNG_LIBRARY="%ROOT_DIR%libpng/install/lib/libpng18_static.lib" ^
  -DJPEG_INCLUDE_DIR="%ROOT_DIR%libjpeg-turbo/install/include" ^
  -DJPEG_LIBRARY="%ROOT_DIR%libjpeg-turbo/install/lib/jpeg-static.lib" ^
  -DGIF_INCLUDE_DIR="%ROOT_DIR%giflib" ^
  -DGIF_LIBRARY="%ROOT_DIR%giflib/libgif.a" ^
  -DCMAKE_PREFIX_PATH="%ROOT_DIR%openexr/install;%ROOT_DIR%Imath/install"
ninja -C build
