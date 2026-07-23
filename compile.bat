@echo off
set "ROOT_DIR=%~dp0"
set "ROOT_DIR=%ROOT_DIR:\=/%"

set "CFLAGS=-flto -O3 -DNDEBUG"
set "CXXFLAGS=-flto -O3 -DNDEBUG"

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
echo make libgif.a CFLAGS="-std=gnu99 -Wall -O3 -flto -D_MT -Xclang --dependent-lib=libcmt"
) | C:\msys64\usr\bin\bash.exe -l

cmake --fresh -B build -G Ninja ^
  -DCMAKE_BUILD_TYPE=Release ^
  -DJPEGXL_STATIC=ON ^
  -DBUILD_TESTING=OFF ^
  -DJPEGXL_ENABLE_BENCHMARK=OFF ^
  -DJPEGXL_ENABLE_MANPAGES=OFF ^
  -DJPEGXL_ENABLE_OPENEXR=OFF ^
  -DJPEGXL_ENABLE_TCMALLOC=OFF ^
  -DZLIB_INCLUDE_DIR="%ROOT_DIR%zlib/install/include" ^
  -DZLIB_LIBRARY="%ROOT_DIR%zlib/install/lib/zs.lib" ^
  -DPNG_PNG_INCLUDE_DIR="%ROOT_DIR%libpng/install/include" ^
  -DPNG_LIBRARY="%ROOT_DIR%libpng/install/lib/libpng18_static.lib" ^
  -DJPEG_INCLUDE_DIR="%ROOT_DIR%libjpeg-turbo/install/include" ^
  -DJPEG_LIBRARY="%ROOT_DIR%libjpeg-turbo/install/lib/jpeg-static.lib" ^
  -DGIF_INCLUDE_DIR="%ROOT_DIR%giflib" ^
  -DGIF_LIBRARY="%ROOT_DIR%giflib/libgif.a"
ninja -C build
